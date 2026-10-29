-- Organizm 5: Konto firmy na platformie
-- Profil, pod którym ktoś publikuje ogłoszenia – zanim wiemy, jaka firma za nim stoi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG05_AccountType (
    AccountTypeKey   NUMBER(2)     NOT NULL,
    AccountTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG05_AccountStatus (
    AccountStatusKey   NUMBER(2)     NOT NULL,
    AccountStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG05_EmployerAccount (
    EmployerAccountKey    NUMBER(8)     NOT NULL,
    SourcePlatformKey     NUMBER(4)     NOT NULL,
    ExternalAccountId     VARCHAR2(50)  NOT NULL,
    AccountTypeKey        NUMBER(2)     NOT NULL,
    AccountStatusKey      NUMBER(2)     NOT NULL,
    IsVerifiedByPlatform  CHAR(1)       NOT NULL,
    FirstSeenAt           TIMESTAMP     NOT NULL
);

CREATE TABLE ORG05_EmployerAccountVersion (
    EmployerAccountVersionKey  NUMBER(9)      NOT NULL,
    EmployerAccountKey         NUMBER(8)      NOT NULL,
    AccountName                VARCHAR2(200)  NOT NULL,
    DeclaredNIP                VARCHAR2(10),
    WebsiteURL                 VARCHAR2(200),
    ValidFrom                  TIMESTAMP      NOT NULL,
    ValidTo                    TIMESTAMP,
    RawRecordKey               NUMBER(12)
);

COMMENT ON TABLE ORG05_AccountType IS 'Kto prowadzi konto.';
COMMENT ON COLUMN ORG05_AccountType.AccountTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_AccountType.AccountTypeName IS 'Nazwa rodzaju konta';

COMMENT ON TABLE ORG05_AccountStatus IS 'Stan konta na platformie.';
COMMENT ON COLUMN ORG05_AccountStatus.AccountStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_AccountStatus.AccountStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG05_EmployerAccount IS 'Konto na jednej platformie.';
COMMENT ON COLUMN ORG05_EmployerAccount.EmployerAccountKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_EmployerAccount.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG05_EmployerAccount.ExternalAccountId IS 'Numer konta w serwisie';
COMMENT ON COLUMN ORG05_EmployerAccount.AccountTypeKey IS 'Kto prowadzi konto';
COMMENT ON COLUMN ORG05_EmployerAccount.AccountStatusKey IS 'Stan konta';
COMMENT ON COLUMN ORG05_EmployerAccount.IsVerifiedByPlatform IS 'Czy platforma sama sprawdziła firmę';
COMMENT ON COLUMN ORG05_EmployerAccount.FirstSeenAt IS 'Kiedy pierwszy raz dostaliśmy to konto';

COMMENT ON TABLE ORG05_EmployerAccountVersion IS 'Wersja danych konta – każda zmiana to nowy wiersz.';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.EmployerAccountVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.AccountName IS 'Nazwa konta';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.DeclaredNIP IS 'NIP wpisany przez właściciela konta (niesprawdzony)';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.WebsiteURL IS 'Strona www podana w koncie';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.ValidFrom IS 'Od kiedy dane są takie';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.ValidTo IS 'Do kiedy (puste = wersja aktualna)';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.RawRecordKey IS 'Rekord, z którego pochodzi ta wersja';

ALTER TABLE ORG05_AccountType ADD CONSTRAINT ORG05_AccountType_PK PRIMARY KEY (AccountTypeKey);
ALTER TABLE ORG05_AccountType ADD CONSTRAINT ORG05_AccountType_AccountTypeName_UN UNIQUE (AccountTypeName);
ALTER TABLE ORG05_AccountStatus ADD CONSTRAINT ORG05_AccountStatus_PK PRIMARY KEY (AccountStatusKey);
ALTER TABLE ORG05_AccountStatus ADD CONSTRAINT ORG05_AccountStatus_AccountStatusName_UN UNIQUE (AccountStatusName);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_PK PRIMARY KEY (EmployerAccountKey);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_UN UNIQUE (SourcePlatformKey, ExternalAccountId);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_IsVerifiedByPlatform_CK CHECK (IsVerifiedByPlatform IN ('T', 'N'));
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_PK PRIMARY KEY (EmployerAccountVersionKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);

ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_AccountType_FK FOREIGN KEY (AccountTypeKey) REFERENCES ORG05_AccountType (AccountTypeKey);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_AccountStatus_FK FOREIGN KEY (AccountStatusKey) REFERENCES ORG05_AccountStatus (AccountStatusKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
