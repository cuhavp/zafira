CREATE SCHEMA IF NOT EXISTS zafira;

SET SCHEMA 'zafira';

DROP FUNCTION IF EXISTS update_timestamp();
CREATE FUNCTION update_timestamp() RETURNS trigger AS $update_timestamp$
    BEGIN
        NEW.modified_at := current_timestamp;
        RETURN NEW;
    END;
$update_timestamp$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS USERS;
CREATE TABLE USERS (
  ID SERIAL,
  USERNAME VARCHAR(100) NOT NULL,
  PASSWORD VARCHAR(50) NULL DEFAULT '',
  EMAIL VARCHAR(100) NULL,
  FIRST_NAME VARCHAR(100) NULL,
  LAST_NAME VARCHAR(100) NULL,
  LAST_LOGIN TIMESTAMP NULL,
  COVER_PHOTO_URL VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX USERNAME_UNIQUE ON USERS (USERNAME);
CREATE TRIGGER update_timestamp_users BEFORE INSERT OR UPDATE ON USERS
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_SUITES;
CREATE TABLE IF NOT EXISTS TEST_SUITES (
  ID SERIAL,
  NAME VARCHAR(200) NOT NULL,
  DESCRIPTION TEXT NULL,
  FILE_NAME VARCHAR(255) NOT NULL DEFAULT '',
  USER_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_SUITES_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX NAME_FILE_USER_UNIQUE ON TEST_SUITES (NAME, FILE_NAME, USER_ID);
CREATE INDEX FK_TEST_SUITE_USER_ASC ON TEST_SUITES (USER_ID);
CREATE TRIGGER update_timestamp_test_suits BEFORE INSERT OR UPDATE ON TEST_SUITES
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();



DROP TABLE IF EXISTS PROJECTS;
CREATE TABLE IF NOT EXISTS PROJECTS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  DESCRIPTION TEXT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX NAME_UNIQUE ON PROJECTS (NAME);
CREATE TRIGGER update_timestamp_projects BEFORE INSERT OR UPDATE ON PROJECTS
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_CASES;
CREATE TABLE IF NOT EXISTS TEST_CASES (
  ID SERIAL,
  TEST_CLASS VARCHAR(255) NOT NULL,
  TEST_METHOD VARCHAR(100) NOT NULL,
  INFO TEXT NULL,
  TEST_SUITE_ID INT NOT NULL,
  PRIMARY_OWNER_ID INT NOT NULL,
  SECONDARY_OWNER_ID INT NULL,
  PROJECT_ID INT NULL,
  STATUS VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_CASE_TEST_SUITE1
    FOREIGN KEY (TEST_SUITE_ID)
    REFERENCES TEST_SUITES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_CASES_USERS1
    FOREIGN KEY (PRIMARY_OWNER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_CASES_USERS2
    FOREIGN KEY (SECONDARY_OWNER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_CASES_PROJECTS1
    FOREIGN KEY (PROJECT_ID)
    REFERENCES PROJECTS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX FK_TEST_CASE_SUITE_ASC ON TEST_CASES (TEST_SUITE_ID);
CREATE INDEX FK_TEST_CASE_PRIMARY_OWNER_ASC ON TEST_CASES (PRIMARY_OWNER_ID);
CREATE INDEX FK_TEST_CASE_SECONDARY_OWNER_ASC ON TEST_CASES (SECONDARY_OWNER_ID);
CREATE INDEX FK_TEST_CASES_PROJECTS_ASC ON TEST_CASES (PROJECT_ID);
CREATE INDEX TESTCASES_TEST_CLASS_INDEX ON TEST_CASES (TEST_CLASS);
CREATE INDEX TESTCASES_TEST_METHOD_INDEX ON TEST_CASES (TEST_METHOD);
CREATE TRIGGER update_timestamp_test_cases BEFORE INSERT OR UPDATE ON TEST_CASES
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS WORK_ITEMS;
CREATE TABLE IF NOT EXISTS WORK_ITEMS (
  ID SERIAL,
  JIRA_ID VARCHAR(45) NOT NULL,
  TYPE VARCHAR(45) NOT NULL DEFAULT 'TASK',
  HASH_CODE INT NULL,
  DESCRIPTION TEXT NULL,
  USER_ID INT NULL,
  TEST_CASE_ID INT NULL,
  KNOWN_ISSUE BOOLEAN NOT NULL DEFAULT FALSE,
  BLOCKER BOOLEAN NOT NULL DEFAULT FALSE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_WORK_ITEMS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_WORK_ITEMS_TEST_CASES1
    FOREIGN KEY (TEST_CASE_ID)
    REFERENCES TEST_CASES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX WORK_ITEM_UNIQUE ON WORK_ITEMS (JIRA_ID, TYPE, HASH_CODE);
CREATE INDEX FK_WORK_ITEM_USER_ASC ON WORK_ITEMS (USER_ID);
CREATE INDEX FK_WORK_ITEM_TEST_CASE_ASC ON WORK_ITEMS (TEST_CASE_ID);
CREATE TRIGGER update_timestamp_work_items BEFORE INSERT OR UPDATE ON WORK_ITEMS
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();
CREATE INDEX WORK_ITEMS_CREATED_AT_INDEX ON WORK_ITEMS (CREATED_AT);



DROP TABLE IF EXISTS JOBS;
CREATE TABLE IF NOT EXISTS JOBS (
  ID SERIAL,
  USER_ID INT NULL,
  NAME VARCHAR(100) NOT NULL,
  JOB_URL VARCHAR(255) NOT NULL,
  JENKINS_HOST VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_JOBS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX JOB_URL_UNIQUE ON JOBS (JOB_URL);
CREATE INDEX fk_JOBS_USERS1_idx ON JOBS (USER_ID);
CREATE TRIGGER update_timestamp_jobs BEFORE INSERT OR UPDATE ON JOBS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS VIEWS;
CREATE TABLE IF NOT EXISTS VIEWS (
  ID SERIAL,
  PROJECT_ID INT NULL,
  NAME VARCHAR(255) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_VIEWS_PROJECTS1
    FOREIGN KEY (PROJECT_ID)
    REFERENCES PROJECTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_VIEWS_PROJECTS1_idx ON VIEWS (PROJECT_ID);
CREATE UNIQUE INDEX VIEW_NAME_UNIQUE ON VIEWS (NAME);
CREATE TRIGGER update_timestamp_views BEFORE INSERT OR UPDATE ON VIEWS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS JOB_VIEWS;
CREATE TABLE IF NOT EXISTS JOB_VIEWS (
  ID SERIAL,
  JOB_ID INT NOT NULL,
  VIEW_ID INT NOT NULL,
  ENV VARCHAR(255) NOT NULL,
  POSITION INT NOT NULL DEFAULT 0,
  SIZE INT NOT NULL DEFAULT 1,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_JOB_VIEWS_JOBS1
    FOREIGN KEY (JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_JOB_VIEWS_VIEWS1
    FOREIGN KEY (VIEW_ID)
    REFERENCES VIEWS(ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_JOB_VIEWS_JOBS1_idx ON JOB_VIEWS (JOB_ID);
CREATE INDEX fk_JOB_VIEWS_VIEWS1_idx ON JOB_VIEWS (VIEW_ID);
CREATE UNIQUE INDEX JOB_ID_ENV_UNIQUE ON JOB_VIEWS (JOB_ID, ENV);
CREATE TRIGGER update_timestamp_job_views BEFORE INSERT OR UPDATE ON JOB_VIEWS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_RUNS;
CREATE TABLE IF NOT EXISTS TEST_RUNS (
  ID SERIAL,
  CI_RUN_ID VARCHAR(50) NULL,
  USER_ID INT,
  TEST_SUITE_ID INT NOT NULL,
  STATUS VARCHAR(20) NOT NULL,
  SCM_URL VARCHAR(255) NULL,
  SCM_BRANCH VARCHAR(100) NULL,
  SCM_COMMIT VARCHAR(100) NULL,
  CONFIG_XML TEXT NULL,
  WORK_ITEM_ID INT NULL,
  JOB_ID INT NOT NULL,
  BUILD_NUMBER INT NOT NULL,
  STARTED_BY VARCHAR(45) NULL,
  UPSTREAM_JOB_ID INT  NULL,
  UPSTREAM_JOB_BUILD_NUMBER INT NULL,
  PROJECT_ID INT NULL,
  KNOWN_ISSUE BOOLEAN NOT NULL DEFAULT FALSE,
  BLOCKER BOOLEAN NOT NULL DEFAULT FALSE,
  ENV VARCHAR(50) NULL,
  PLATFORM VARCHAR(30) NULL,
  APP_VERSION VARCHAR(255) NULL,
  STARTED_AT TIMESTAMP NULL,
  ELAPSED INT NULL,
  ETA INT NULL,
  COMMENTS TEXT NULL,
  DRIVER_MODE VARCHAR(50) NOT NULL DEFAULT 'METHOD_MODE',
  REVIEWED BOOLEAN NOT NULL DEFAULT FALSE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_RESULTS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RESULTS_TEST_SUITES1
    FOREIGN KEY (TEST_SUITE_ID)
    REFERENCES TEST_SUITES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_WORK_ITEMS1
    FOREIGN KEY (WORK_ITEM_ID)
    REFERENCES WORK_ITEMS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_JOBS1
    FOREIGN KEY (JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_JOBS2
    FOREIGN KEY (UPSTREAM_JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_PROJECTS1
    FOREIGN KEY (PROJECT_ID)
    REFERENCES PROJECTS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX FK_TEST_RUN_USER_ASC ON TEST_RUNS (USER_ID);
CREATE INDEX FK_TEST_RUN_TEST_SUITE_ASC ON TEST_RUNS (TEST_SUITE_ID);
CREATE INDEX fk_TEST_RUNS_WORK_ITEMS1_idx ON TEST_RUNS (WORK_ITEM_ID);
CREATE INDEX fk_TEST_RUNS_JOBS1_idx ON TEST_RUNS (JOB_ID);
CREATE INDEX fk_TEST_RUNS_JOBS2_idx ON TEST_RUNS (UPSTREAM_JOB_ID);
CREATE INDEX fk_TEST_RUNS_PROJECTS1_idx ON TEST_RUNS (PROJECT_ID);
CREATE INDEX TEST_RUNS_STARTED_AT_INDEX ON TEST_RUNS(STARTED_AT ASC NULLS LAST);
CREATE UNIQUE INDEX CI_RUN_ID_UNIQUE ON TEST_RUNS (CI_RUN_ID);
CREATE TRIGGER update_timestamp_test_runs BEFORE INSERT OR UPDATE ON TEST_RUNS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_CONFIGS;
CREATE TABLE IF NOT EXISTS TEST_CONFIGS (
  ID SERIAL,
  URL VARCHAR(512) NULL,
  ENV VARCHAR(50) NULL,
  PLATFORM VARCHAR(30) NULL,
  PLATFORM_VERSION VARCHAR(30) NULL,
  BROWSER VARCHAR(30) NULL,
  BROWSER_VERSION VARCHAR(30) NULL,
  APP_VERSION VARCHAR(255) NULL,
  LOCALE VARCHAR(30) NULL,
  LANGUAGE VARCHAR(30) NULL,
  DEVICE VARCHAR(50) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE TRIGGER update_timestamp_test_configs BEFORE INSERT OR UPDATE ON TEST_CONFIGS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TESTS;
CREATE TABLE IF NOT EXISTS TESTS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  STATUS VARCHAR(20) NOT NULL,
  TEST_ARGS TEXT NULL,
  TEST_RUN_ID INT NOT NULL,
  TEST_CASE_ID INT NOT NULL,
  TEST_GROUP VARCHAR(255),
  MESSAGE TEXT NULL,
  MESSAGE_HASH_CODE INT NULL,
  START_TIME TIMESTAMP NULL,
  FINISH_TIME TIMESTAMP NULL,
  RETRY INT NOT NULL DEFAULT 0,
  TEST_CONFIG_ID INT NULL,
  KNOWN_ISSUE BOOLEAN NOT NULL DEFAULT FALSE,
  BLOCKER BOOLEAN NOT NULL DEFAULT FALSE,
  NEED_RERUN BOOLEAN NOT NULL DEFAULT TRUE,
  DEPENDS_ON_METHODS VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TESTS_TEST_CONFIGS1
    FOREIGN KEY (TEST_CONFIG_ID)
    REFERENCES TEST_CONFIGS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TESTS_TEST_RUNS1
    FOREIGN KEY (TEST_RUN_ID)
    REFERENCES TEST_RUNS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TESTS_TEST_CASES1
    FOREIGN KEY (TEST_CASE_ID)
    REFERENCES TEST_CASES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX fk_TESTS_TEST_RUNS1_idx ON  TESTS (TEST_RUN_ID);
CREATE INDEX fk_TESTS_TEST_CASES1_idx ON  TESTS (TEST_CASE_ID);
CREATE INDEX fk_TESTS_TEST_CONFIGS1_idx ON TESTS (TEST_CONFIG_ID);
CREATE TRIGGER update_timestamp_tests BEFORE INSERT OR UPDATE ON TESTS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS USER_PREFERENCES;
CREATE TABLE IF NOT EXISTS USER_PREFERENCES (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  VALUE VARCHAR(255) NOT NULL ,
  USER_ID INT,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT user_preferences_users_id_fk
  FOREIGN KEY (USER_ID)
  REFERENCES USERS (ID)
  ON DELETE CASCADE
  ON UPDATE NO ACTION);
CREATE UNIQUE INDEX NAME_USER_ID_UNIQUE ON USER_PREFERENCES (NAME, USER_ID);
CREATE TRIGGER update_timestamp_user_preferences BEFORE INSERT OR UPDATE ON USER_PREFERENCES FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_ARTIFACTS;
CREATE TABLE IF NOT EXISTS TEST_ARTIFACTS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  LINK TEXT NOT NULL,
  EXPIRES_AT TIMESTAMP NULL,
  TEST_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_ARTIFACTS_TESTS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_TEST_ARTIFACTS_TESTS1_idx ON TEST_ARTIFACTS (TEST_ID);
CREATE UNIQUE INDEX NAME_TEST_ID_UNIQUE ON TEST_ARTIFACTS (NAME, TEST_ID);
CREATE TRIGGER update_timestamp_test_artifacts BEFORE INSERT OR UPDATE ON TEST_ARTIFACTS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();



DROP TABLE IF EXISTS TEST_WORK_ITEMS;
CREATE TABLE IF NOT EXISTS TEST_WORK_ITEMS (
  ID SERIAL,
  TEST_ID INT NOT NULL,
  WORK_ITEM_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_WORK_ITEMS_TESTS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_WORK_ITEMS_WORK_ITEMS1
    FOREIGN KEY (WORK_ITEM_ID)
    REFERENCES WORK_ITEMS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX fk_TEST_WORK_ITEMS_TESTS1_idx ON  TEST_WORK_ITEMS (TEST_ID);
CREATE INDEX fk_TEST_WORK_ITEMS_WORK_ITEMS1_idx ON  TEST_WORK_ITEMS (WORK_ITEM_ID);
CREATE TRIGGER update_timestamp_test_work_items BEFORE INSERT OR UPDATE ON TEST_WORK_ITEMS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_METRICS;
CREATE TABLE IF NOT EXISTS TEST_METRICS (
  ID SERIAL,
  OPERATION VARCHAR(127) NOT NULL,
  ELAPSED BIGINT NOT NULL,
  TEST_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_METRICS_TESTS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_TEST_METRICS_TESTS1_idx ON  TEST_METRICS (TEST_ID);
CREATE INDEX TEST_OPERATION ON  TEST_METRICS (OPERATION);
CREATE TRIGGER update_timestamp_test_metrics BEFORE INSERT OR UPDATE ON TEST_METRICS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS SETTINGS;
CREATE TABLE IF NOT EXISTS SETTINGS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  VALUE VARCHAR(255) NULL,
  IS_ENCRYPTED BOOLEAN NULL DEFAULT FALSE,
  TOOL VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX SETTING_UNIQUE ON SETTINGS (NAME);
CREATE TRIGGER update_timestamp_settings BEFORE INSERT OR UPDATE ON SETTINGS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS WIDGETS;
CREATE TABLE IF NOT EXISTS WIDGETS (
  ID SERIAL,
  TITLE VARCHAR(255) NOT NULL,
  TYPE VARCHAR(20) NOT NULL DEFAULT 'linechart',
  SQL TEXT NOT NULL,
  MODEL TEXT NOT NULL,
  REFRESHABLE BOOLEAN NOT NULL DEFAULT false NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE TRIGGER update_timestamp_widgets BEFORE INSERT OR UPDATE ON WIDGETS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS DASHBOARDS;
CREATE TABLE IF NOT EXISTS DASHBOARDS (
  ID SERIAL,
  TITLE VARCHAR(255) NOT NULL,
  HIDDEN BOOLEAN NOT NULL DEFAULT FALSE,
  POSITION INT NOT NULL DEFAULT 0,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE INDEX TITLE_UNIQUE ON DASHBOARDS (TITLE);
CREATE TRIGGER update_timestamp_dashboards BEFORE INSERT OR UPDATE ON DASHBOARDS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS DASHBOARDS_WIDGETS;
CREATE TABLE IF NOT EXISTS DASHBOARDS_WIDGETS (
  ID SERIAL,
  DASHBOARD_ID INT NOT NULL,
  WIDGET_ID INT NOT NULL,
  POSITION INT NULL DEFAULT 0,
  SIZE INT NULL DEFAULT 1,
  LOCATION VARCHAR(255) NOT NULL DEFAULT '',
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_DASHBOARDS_WIDGETS_DASHBOARDS1
    FOREIGN KEY (DASHBOARD_ID)
    REFERENCES DASHBOARDS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_DASHBOARDS_WIDGETS_WIDGETS1
    FOREIGN KEY (WIDGET_ID)
    REFERENCES WIDGETS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_DASHBOARDS_WIDGETS_DASHBOARDS1_idx ON DASHBOARDS_WIDGETS (DASHBOARD_ID);
CREATE INDEX fk_DASHBOARDS_WIDGETS_WIDGETS1_idx ON DASHBOARDS_WIDGETS (WIDGET_ID);
CREATE UNIQUE INDEX DASHBOARD_WIDGET_UNIQUE ON DASHBOARDS_WIDGETS (DASHBOARD_ID, WIDGET_ID);
CREATE TRIGGER update_timestamp_dashboards_widgets BEFORE INSERT OR UPDATE ON DASHBOARDS_WIDGETS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS GROUPS;
CREATE TABLE IF NOT EXISTS GROUPS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  ROLE VARCHAR(255) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX GROUP_UNIQUE ON GROUPS (NAME);
CREATE TRIGGER update_timestamp_groups BEFORE INSERT OR UPDATE ON GROUPS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS USER_GROUPS;
CREATE TABLE IF NOT EXISTS USER_GROUPS (
  ID SERIAL,
  GROUP_ID INT NOT NULL,
  USER_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_USER_GROUPS_GROUPS1
    FOREIGN KEY (GROUP_ID)
    REFERENCES GROUPS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_USER_GROUPS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_USER_GROUPS_GROUPS1_idx ON USER_GROUPS (GROUP_ID);
CREATE INDEX fk_USER_GROUPS_USERS1_idx ON USER_GROUPS (USER_ID);
CREATE UNIQUE INDEX USER_GROUP_UNIQUE ON USER_GROUPS (USER_ID, GROUP_ID);
CREATE TRIGGER update_timestamp_user_groups BEFORE INSERT OR UPDATE ON USER_GROUPS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS PERMISSIONS;
CREATE TABLE IF NOT EXISTS PERMISSIONS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  BLOCK VARCHAR(50) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX PERMISSION_UNIQUE ON PERMISSIONS (NAME);
CREATE TRIGGER update_timestamp_permissions BEFORE INSERT OR UPDATE ON PERMISSIONS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS GROUP_PERMISSIONS;
CREATE TABLE IF NOT EXISTS GROUP_PERMISSIONS (
  ID SERIAL,
  GROUP_ID INT NOT NULL,
  PERMISSION_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_GROUP_PERMISSIONS_GROUPS1
    FOREIGN KEY (GROUP_ID)
    REFERENCES GROUPS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_GROUP_PERMISSIONS_PERMISSIONS1
    FOREIGN KEY (PERMISSION_ID)
    REFERENCES PERMISSIONS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_GROUP_PERMISSIONS_GROUPS1_idx ON GROUP_PERMISSIONS (GROUP_ID);
CREATE INDEX fk_GROUP_PERMISSIONS_PERMISSIONS1_idx ON GROUP_PERMISSIONS (PERMISSION_ID);
CREATE UNIQUE INDEX GROUP_PERMISSION_UNIQUE ON GROUP_PERMISSIONS (PERMISSION_ID, GROUP_ID);
CREATE TRIGGER update_timestamp_group_premissions BEFORE INSERT OR UPDATE ON GROUP_PERMISSIONS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS DASHBOARD_ATTRIBUTES;
CREATE TABLE IF NOT EXISTS DASHBOARD_ATTRIBUTES (
  ID SERIAL,
  KEY VARCHAR(255) NOT NULL,
  VALUE VARCHAR(255) NOT NULL,
  DASHBOARD_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_DASHBOARD_ATTRIBUTES_DASHBOARDS1
    FOREIGN KEY (DASHBOARD_ID)
    REFERENCES DASHBOARDS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_DASHBOARD_ATTRIBUTES_DASHBOARDS1_idx ON DASHBOARD_ATTRIBUTES (DASHBOARD_ID);
CREATE UNIQUE INDEX DASHBOARD_KEY_UNIQUE ON DASHBOARD_ATTRIBUTES (KEY, DASHBOARD_ID);
CREATE TRIGGER update_timestamp_dashboard_attributes BEFORE INSERT OR UPDATE ON DASHBOARD_ATTRIBUTES FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS MONITORS ;

CREATE TABLE IF NOT EXISTS MONITORS (
  ID SERIAL,
  NAME VARCHAR(45) NOT NULL,
  URL VARCHAR(500) NOT NULL,
  HTTP_METHOD VARCHAR(45) NULL,
  REQUEST_BODY TEXT NULL,
  NOTIFICATIONS_ENABLED BOOLEAN NOT NULL DEFAULT FALSE,
  MONITOR_ENABLED BOOLEAN NOT NULL DEFAULT TRUE,
  TYPE VARCHAR(45) NOT NULL,
  RECIPIENTS VARCHAR(500) NULL,
  CRON_EXPRESSION VARCHAR(45) NOT NULL,
  EXPECTED_CODE INT NOT NULL,
  SUCCESS BOOLEAN NOT NULL DEFAULT FALSE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
  CREATE UNIQUE INDEX MONITORS_NAME_UNIQUE ON MONITORS (NAME);
  CREATE TRIGGER update_timestamp_monitors BEFORE INSERT OR UPDATE ON MONITORS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

--DELETE OR DETACH ALL TESTS WHERE CREATED_AT::date < '2016-01-01'

DROP MATERIALIZED VIEW IF EXISTS TOTAL_VIEW;
CREATE MATERIALIZED VIEW TOTAL_VIEW AS (
  SELECT row_number() OVER () AS ID,
         PROJECTS.NAME AS PROJECT,
         USERS.ID AS OWNER_ID,
         USERS.USERNAME AS OWNER,
         TEST_CONFIGS.ENV as Env,
         sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
         sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
         sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
         sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
         sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
         sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
         COUNT(*) AS TOTAL,
         date_trunc('month', TESTS.CREATED_AT) AS TESTED_AT,
         sum(EXTRACT(epoch FROM (TESTS.FINISH_TIME - TESTS.START_TIME))/60)::bigint as TOTAL_MINUTES,
         sum(EXTRACT(epoch FROM(TESTS.FINISH_TIME - TESTS.START_TIME))/3600)::bigint as TOTAL_HOURS,
         avg(TESTS.FINISH_TIME - TESTS.START_TIME) as AVG_TIME
  FROM TESTS INNER JOIN
    TEST_CASES ON TESTS.TEST_CASE_ID = TEST_CASES.ID INNER JOIN
    USERS ON TEST_CASES.PRIMARY_OWNER_ID = USERS.ID  INNER JOIN
    TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID LEFT JOIN
    PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID
  WHERE TESTS.FINISH_TIME IS NOT NULL
        AND TESTS.START_TIME IS NOT NULL
        AND TESTS.START_TIME < date_trunc('month', current_date)
        AND PROJECTS.NAME <> 'Unknown'
        AND PROJECTS.NAME <> ''
        AND PROJECTS.NAME <> 'UADEMO'
  GROUP BY PROJECT, OWNER_ID, OWNER, Env, TESTED_AT
  ORDER BY TESTED_AT
);

DROP INDEX IF EXISTS TOTAL_VIEW_INDEX;
CREATE UNIQUE INDEX TOTAL_VIEW_INDEX ON TOTAL_VIEW (ID);

DROP INDEX IF EXISTS TOTAL_VIEW_PROJECT_INDEX;
CREATE INDEX TOTAL_VIEW_PROJECT_INDEX ON TOTAL_VIEW (PROJECT);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_ID_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_ID_INDEX ON TOTAL_VIEW (OWNER_ID);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_INDEX ON TOTAL_VIEW (OWNER);

DROP INDEX IF EXISTS TOTAL_VIEW_ENV_INDEX;
CREATE INDEX TOTAL_VIEW_ENV_INDEX ON TOTAL_VIEW (Env);

DROP INDEX IF EXISTS TOTAL_VIEW_TESTED_AT_INDEX;
CREATE INDEX TOTAL_VIEW_TESTED_AT_INDEX ON TOTAL_VIEW (TESTED_AT);

SELECT cron.schedule ('0 0 1 * *', $$REFRESH MATERIALIZED VIEW ZAFIRA.TOTAL_VIEW$$);


--Tests for the period from the beginning of previous month till previous day incl.
DROP MATERIALIZED VIEW IF EXISTS BIMONTHLY_VIEW;
CREATE MATERIALIZED VIEW BIMONTHLY_VIEW AS (
  SELECT  row_number() OVER () AS ID,
          PROJECTS.NAME AS PROJECT,
          USERS.ID AS OWNER_ID,
          USERS.USERNAME AS OWNER,
          USERS.EMAIL AS EMAIL,
          TEST_RUNS.ENV as Env,
          TEST_CONFIGS.PLATFORM as Platform,
          TEST_CONFIGS.BROWSER as Browser,
          TEST_CONFIGS.APP_VERSION as Build,
          JOBS.JOB_URL AS Job,
          TEST_SUITES.USER_ID AS JOB_OWNER_ID,
          TEST_RUNS.ID AS TEST_RUN_ID,
          TEST_RUNS.BUILD_NUMBER As JobBuild,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/eTAF_Report' || '" target="_blank">' || JOBS.NAME || '</a>' as eTAF_Report,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/rebuild/parameterized' || '" target="_blank">Rebuild</a>' as Rebuild,
          TEST_RUNS.ELAPSED AS Elapsed,
          TEST_RUNS.STARTED_AT AS Started,
          TEST_RUNS.CREATED_AT::date AS Updated,
          TEST_RUNS.UPSTREAM_JOB_ID AS UPSTREAM_JOB_ID,
          TEST_RUNS.UPSTREAM_JOB_BUILD_NUMBER AS UPSTREAM_JOB_BUILD_NUMBER,
          TEST_RUNS.SCM_URL AS GIT_REPO,
          sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
          sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
          sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
          sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
          count( TESTS.STATUS ) AS TOTAL,
          sum(EXTRACT(epoch FROM(TESTS.FINISH_TIME - TESTS.START_TIME))/3600)::bigint as TOTAL_HOURS
  FROM TESTS INNER JOIN
    TEST_RUNS ON TEST_RUNS.ID=TESTS.TEST_RUN_ID INNER JOIN
    TEST_CASES ON TESTS.TEST_CASE_ID=TEST_CASES.ID INNER JOIN
    TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID LEFT JOIN
    PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID INNER JOIN
    JOBS ON TEST_RUNS.JOB_ID = JOBS.ID INNER JOIN
    USERS ON TEST_CASES.PRIMARY_OWNER_ID=USERS.ID INNER JOIN
    TEST_SUITES ON TEST_RUNS.TEST_SUITE_ID = TEST_SUITES.ID
  WHERE TESTS.CREATED_AT >= date_trunc('month', current_date - interval '1 month')
        AND TEST_RUNS.STARTED_AT >= date_trunc('month', current_date - interval '1 month')
        AND TEST_RUNS.STARTED_AT < date_trunc('day', current_date)
  GROUP BY PROJECT, TEST_RUNS.ID, USERS.ID, TEST_CONFIGS.PLATFORM, TEST_CONFIGS.BROWSER, TEST_CONFIGS.APP_VERSION, JOBS.JOB_URL, JOBS.NAME, TEST_SUITES.USER_ID);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_ID_INDEX;
CREATE UNIQUE INDEX BIMONTHLY_VIEW_ID_INDEX ON BIMONTHLY_VIEW (ID);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_PROJECT_INDEX;
CREATE INDEX BIMONTHLY_VIEW_PROJECT_INDEX ON BIMONTHLY_VIEW (PROJECT);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_OWNER_ID_INDEX;
CREATE INDEX BIMONTHLY_VIEW_OWNER_ID_INDEX ON BIMONTHLY_VIEW (OWNER_ID);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_OWNER_INDEX;
CREATE INDEX BIMONTHLY_VIEW_OWNER_INDEX ON BIMONTHLY_VIEW (OWNER);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_EMAIL_INDEX;
CREATE INDEX BIMONTHLY_VIEW_EMAIL_INDEX ON BIMONTHLY_VIEW (EMAIL);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_ENV_INDEX;
CREATE INDEX BIMONTHLY_VIEW_ENV_INDEX ON BIMONTHLY_VIEW (Env);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_PLATFORM_INDEX;
CREATE INDEX BIMONTHLY_VIEW_PLATFORM_INDEX ON BIMONTHLY_VIEW (Platform);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_BROWSER_INDEX;
CREATE INDEX BIMONTHLY_VIEW_BROWSER_INDEX ON BIMONTHLY_VIEW (Browser);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_BROWSER_INDEX;
CREATE INDEX BIMONTHLY_VIEW_BROWSER_INDEX ON BIMONTHLY_VIEW (Build);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_JOB_INDEX;
CREATE INDEX BIMONTHLY_VIEW_JOB_INDEX ON BIMONTHLY_VIEW (Job);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_JOB_OWNER_ID_INDEX;
CREATE INDEX BIMONTHLY_VIEW_JOB_OWNER_ID_INDEX ON BIMONTHLY_VIEW (JOB_OWNER_ID);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_JOB_BUILD_INDEX;
CREATE INDEX BIMONTHLY_VIEW_JOB_BUILD_INDEX ON BIMONTHLY_VIEW (JobBuild);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_ELAPSED_INDEX;
CREATE INDEX BIMONTHLY_VIEW_ELAPSED_INDEX ON BIMONTHLY_VIEW (Elapsed);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_STARTED_INDEX;
CREATE INDEX BIMONTHLY_VIEW_STARTED_INDEX ON BIMONTHLY_VIEW (Started);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_UPDATED_INDEX;
CREATE INDEX BIMONTHLY_VIEW_UPDATED_INDEX ON BIMONTHLY_VIEW (Updated);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_ETAF_REPORT_INDEX;
CREATE INDEX BIMONTHLY_VIEW_ETAF_REPORT_INDEX ON BIMONTHLY_VIEW (eTAF_Report);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_REBUILD_INDEX;
CREATE INDEX BIMONTHLY_VIEW_REBUILD_INDEX ON BIMONTHLY_VIEW (Rebuild);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_UPSTREAM_JOB_ID_INDEX;
CREATE INDEX BIMONTHLY_VIEW_UPSTREAM_JOB_ID_INDEX ON BIMONTHLY_VIEW (UPSTREAM_JOB_ID);

DROP INDEX IF EXISTS BIMONTHLY_VIEW_UPSTREAM_JOB_BUILD_NUMBER_INDEX;
CREATE INDEX BIMONTHLY_VIEW_UPSTREAM_JOB_BUILD_NUMBER_INDEX ON BIMONTHLY_VIEW (UPSTREAM_JOB_BUILD_NUMBER);

SELECT cron.schedule ('0 7 * * *', $$REFRESH MATERIALIZED VIEW ZAFIRA.BIMONTHLY_VIEW$$);

DROP VIEW IF EXISTS WEEKLY_VIEW;
CREATE VIEW WEEKLY_VIEW AS (
  SELECT  row_number() OVER () AS ID,
          PROJECTS.NAME AS PROJECT,
          USERS.ID AS OWNER_ID,
          USERS.USERNAME AS OWNER,
          USERS.EMAIL AS EMAIL,
          TEST_RUNS.ENV as Env,
          TEST_CONFIGS.PLATFORM as Platform,
          TEST_CONFIGS.BROWSER as Browser,
          TEST_CONFIGS.APP_VERSION as Build,
          JOBS.JOB_URL AS Job,
          TEST_SUITES.USER_ID AS JOB_OWNER_ID,
          TEST_RUNS.ID AS TEST_RUN_ID,
          TEST_RUNS.BUILD_NUMBER As JobBuild,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/eTAF_Report' || '" target="_blank">' || JOBS.NAME || '</a>' as eTAF_Report,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/rebuild/parameterized' || '" target="_blank">Rebuild</a>' as Rebuild,
          TEST_RUNS.ELAPSED AS Elapsed,
          TEST_RUNS.STARTED_AT AS Started,
          TEST_RUNS.CREATED_AT::date AS Updated,
          TEST_RUNS.UPSTREAM_JOB_ID AS UPSTREAM_JOB_ID,
          TEST_RUNS.UPSTREAM_JOB_BUILD_NUMBER AS UPSTREAM_JOB_BUILD_NUMBER,
          TEST_RUNS.SCM_URL AS GIT_REPO,
          sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
          sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
          sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
          sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
          count( TESTS.STATUS ) AS TOTAL
  FROM TESTS INNER JOIN
    TEST_RUNS ON TEST_RUNS.ID=TESTS.TEST_RUN_ID INNER JOIN
    TEST_CASES ON TESTS.TEST_CASE_ID=TEST_CASES.ID INNER JOIN
    TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID LEFT JOIN
    PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID INNER JOIN
    JOBS ON TEST_RUNS.JOB_ID = JOBS.ID INNER JOIN
    USERS ON TEST_CASES.PRIMARY_OWNER_ID=USERS.ID INNER JOIN
    TEST_SUITES ON TEST_RUNS.TEST_SUITE_ID = TEST_SUITES.ID
  WHERE TESTS.CREATED_AT >= date_trunc('day', date_trunc('week', current_date)  - interval '2 day')
        AND TEST_RUNS.STARTED_AT >= date_trunc('day', date_trunc('week', current_date)  - interval '2 day')
  GROUP BY PROJECTS.NAME, TEST_RUNS.ID, USERS.ID, TEST_CONFIGS.PLATFORM, TEST_CONFIGS.BROWSER, TEST_CONFIGS.APP_VERSION, JOBS.JOB_URL, JOBS.NAME, TEST_SUITES.USER_ID
);


DROP VIEW IF EXISTS NIGHTLY_VIEW;
CREATE VIEW NIGHTLY_VIEW AS (
  SELECT  row_number() OVER () AS ID,
          PROJECTS.NAME AS PROJECT,
          USERS.ID AS OWNER_ID,
          USERS.USERNAME AS OWNER,
          USERS.EMAIL AS EMAIL,
          TEST_RUNS.ENV as Env,
          TEST_CONFIGS.PLATFORM as Platform,
          TEST_CONFIGS.BROWSER as Browser,
          TEST_CONFIGS.APP_VERSION as Build,
          JOBS.JOB_URL AS Job,
          TEST_SUITES.USER_ID AS JOB_OWNER_ID,
          TEST_RUNS.ID AS TEST_RUN_ID,
          TEST_RUNS.BUILD_NUMBER As JobBuild,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/eTAF_Report' || '" target="_blank">' || JOBS.NAME || '</a>' as eTAF_Report,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/rebuild/parameterized' || '" target="_blank">Rebuild</a>' as Rebuild,
          TEST_RUNS.ELAPSED AS Elapsed,
          TEST_RUNS.STARTED_AT AS Started,
          TEST_RUNS.CREATED_AT::date AS Updated,
          TEST_RUNS.UPSTREAM_JOB_ID AS UPSTREAM_JOB_ID,
          TEST_RUNS.UPSTREAM_JOB_BUILD_NUMBER AS UPSTREAM_JOB_BUILD_NUMBER,
          TEST_RUNS.SCM_URL AS GIT_REPO,
          sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
          sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
          sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
          sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
          count( TESTS.STATUS ) AS TOTAL
  FROM TESTS INNER JOIN
    TEST_RUNS ON TEST_RUNS.ID=TESTS.TEST_RUN_ID INNER JOIN
    TEST_CASES ON TESTS.TEST_CASE_ID=TEST_CASES.ID INNER JOIN
    TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID LEFT JOIN
    PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID INNER JOIN
    JOBS ON TEST_RUNS.JOB_ID = JOBS.ID INNER JOIN
    USERS ON TEST_CASES.PRIMARY_OWNER_ID=USERS.ID INNER JOIN
    TEST_SUITES ON TEST_RUNS.TEST_SUITE_ID = TEST_SUITES.ID
  WHERE TESTS.CREATED_AT >= date_trunc('day', current_date)
        AND TEST_RUNS.STARTED_AT >= date_trunc('day', current_date)
  GROUP BY PROJECTS.NAME, TEST_RUNS.ID, USERS.ID, TEST_CONFIGS.PLATFORM, TEST_CONFIGS.BROWSER, TEST_CONFIGS.APP_VERSION, JOBS.JOB_URL, JOBS.NAME, TEST_SUITES.USER_ID
);
