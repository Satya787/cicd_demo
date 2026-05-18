# Snowflake GitHub OIDC Setup

This pipeline uses Snowflake workload identity federation (WIF) with GitHub Actions OIDC. The GitHub runner receives a short-lived OIDC token and Snowflake validates the token instead of using a stored private key.

## 1. Choose the GitHub subject

The workflow job uses the `dev` GitHub environment:

```yaml
environment: dev
```

For this setup, the Snowflake service user subject must be:

```text
repo:<github-owner>/<github-repo>:environment:dev
```

Example:

```text
repo:my-org/snowflake_dbt_cicd_demo:environment:dev
```

## 2. Create the deploy role and service user

Run this as a Snowflake administrator. Replace the placeholders before running.

```sql
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS DBT_DEPLOY_ROLE;

USE ROLE USERADMIN;

CREATE USER GITHUB_DBT_DEPLOY_SVC
  TYPE = SERVICE
  DEFAULT_ROLE = DBT_DEPLOY_ROLE
  DEFAULT_WAREHOUSE = <warehouse_name>
  WORKLOAD_IDENTITY = (
    TYPE = OIDC
    ISSUER = 'https://token.actions.githubusercontent.com'
    SUBJECT = 'repo:<github-owner>/<github-repo>:environment:dev'
  );
```

If the user already exists, update the workload identity:

```sql
ALTER USER GITHUB_DBT_DEPLOY_SVC SET
  WORKLOAD_IDENTITY = (
    TYPE = OIDC
    ISSUER = 'https://token.actions.githubusercontent.com'
    SUBJECT = 'repo:<github-owner>/<github-repo>:environment:dev'
  );
```

## 3. Grant least-privilege access

Adjust names to match your database, schema, warehouse, and deployment model.

```sql
USE ROLE SECURITYADMIN;

GRANT USAGE ON WAREHOUSE <warehouse_name> TO ROLE DBT_DEPLOY_ROLE;
GRANT USAGE ON DATABASE <database_name> TO ROLE DBT_DEPLOY_ROLE;
GRANT USAGE ON SCHEMA <database_name>.<schema_name> TO ROLE DBT_DEPLOY_ROLE;
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
  ON SCHEMA <database_name>.<schema_name>
  TO ROLE DBT_DEPLOY_ROLE;

GRANT ROLE DBT_DEPLOY_ROLE TO USER GITHUB_DBT_DEPLOY_SVC;
```

Add any extra privileges your dbt models need, such as `CREATE DYNAMIC TABLE`, `CREATE TASK`, or read access to source schemas.

## 4. Configure GitHub repository

Create the `dev` environment in GitHub:

1. Repository `Settings` -> `Environments`.
2. Create environment `dev`.
3. Optional but recommended: add environment protection rules or required reviewers.

Set these as GitHub repository or environment variables:

```text
SNOWFLAKE_ACCOUNT
SNOWFLAKE_USER
SNOWFLAKE_DATABASE
SNOWFLAKE_SCHEMA
SNOWFLAKE_WAREHOUSE
SNOWFLAKE_ROLE
```

Set `SNOWFLAKE_USER` to the service user, for example `GITHUB_DBT_DEPLOY_SVC`.

Delete this old secret after the first successful OIDC deployment:

```text
SNOWFLAKE_PRIVATE_KEY
```

## 5. Deploy

Commit and push the workflow change to `main`, or run it manually from GitHub Actions:

```bash
git add .github/workflows/deploy_dbt_project.yaml docs/snowflake-github-oidc-setup.md
git commit -m "Use Snowflake OIDC for dbt deployment"
git push origin main
```

The workflow should first pass:

```bash
snow connection test --connection develop
```

Then it deploys the dbt project and executes the selected models and tests.

The workflow names the OIDC token `SNOWFLAKE_CONNECTIONS_DEVELOP_TOKEN` so it is scoped to the `develop` Snowflake CLI connection.

## 6. Verify in Snowflake

After the workflow runs, check recent logins:

```sql
SELECT
  EVENT_TIMESTAMP,
  USER_NAME,
  CLIENT_IP,
  REPORTED_CLIENT_TYPE,
  FIRST_AUTHENTICATION_FACTOR
FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
WHERE USER_NAME = 'GITHUB_DBT_DEPLOY_SVC'
ORDER BY EVENT_TIMESTAMP DESC;
```

You can also inspect workload identity methods:

```sql
SHOW USER WORKLOAD IDENTITY AUTHENTICATION METHODS FOR USER GITHUB_DBT_DEPLOY_SVC;
```
