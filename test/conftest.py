def pytest_addoption(parser):
    parser.addini("project", "Project name for tests")
    parser.addini("environment", "Environment name for tests")
    parser.addini("session", "STS session name prefix")
    parser.addini("aws_region", "AWS region for tests")
    parser.addini("profile", "AWS CLI profile for tests")
    parser.addini("test_role_arn", "Role ARN to assume for AWS tests")
