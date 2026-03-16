import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import functions as F
from pyspark.sql.types import TimestampType

# @params: [JOB_NAME, BRONZE_PATH, DATABASE_NAME, TABLE_NAME]
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'SOURCE_DATABASE',
    'SOURCE_TABLE',
    'OUTPUT_DATABASE',
    'OUTPUT_PATH'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 1. Read JSON from Bronze Glue Data Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database=args["SOURCE_DATABASE"],
    table_name=args["SOURCE_TABLE"]
)
bronze_df = datasource.toDF()

# Define the HN item types we want to process
hn_types = ["story", "job", "poll", "comment", "pollopt"]

# 2. Silver Transformations
for item_type in hn_types:
    type_df = bronze_df.filter(F.col("type") == item_type)
    
    silver_typed_df = (
        type_df
        .dropna(subset=["id"])  # Ensure data integrity
        .dropDuplicates(["id"]) # Drop duplicates based on 'id' field

        # Convert Unix 'time' to Timestamp
        .withColumn("time", F.from_unixtime(F.col("time")).cast(TimestampType()))

        # Create Partitioning Columns
        .withColumn("year", F.year(F.col("time")))
        .withColumn("month", F.month(F.col("time")))
        .withColumn("day", F.dayofmonth(F.col("time")))

        # Standardize common HN fields
        .withColumn("score", F.col("score").cast("integer"))
        .withColumn("descendants", F.col("descendants").cast("integer"))
        
        # .withColumn("is_deleted", col("deleted") | col("dead"))
    )

    # 3. Save as a Managed Table in the Glue Data Catalog
    # This creates the table in the specified Database and saves files in Parquet format
    silver_df.write \
        .mode("overwrite") \
        .partitionBy("year", "month", "day") \
        .format("parquet") \
        .option("path", args["OUTPUT_PATH"]) \
        .saveAsTable(f"{args['OUTPUT_DATABASE']}.stories")

job.commit()
