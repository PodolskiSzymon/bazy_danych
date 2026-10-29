-- Organizm 5: Konto firmy na platformie
-- Profil, pod którym ktoś publikuje ogłoszenia – zanim wiemy, jaka firma za nim stoi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE AccountType (
    AccountTypeKey   NUMBER(2)     NOT NULL,
    AccountTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE AccountStatus (
    AccountStatusKey   NUMBER(2)     NOT NULL,
    AccountStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE EmployerAccount (
    EmployerAccountKey    NUMBER(8)     NOT NULL,
    SourcePlatformKey     NUMBER(4)     NOT NULL,
    ExternalAccountId     VARCHAR2(50)  NOT NULL,
    AccountTypeKey        NUMBER(2)     NOT NULL,
    AccountStatusKey      NUMBER(2)     NOT NULL,
    IsVerifiedByPlatform  CHAR(1)       NOT NULL,
    FirstSeenAt           TIMESTAMP     NOT NULL
);

CREATE TABLE EmployerAccountVersion (
    EmployerAccountVersionKey  NUMBER(9)      NOT NULL,
    EmployerAccountKey         NUMBER(8)      NOT NULL,
    AccountName                VARCHAR2(200)  NOT NULL,
    DeclaredNIP                VARCHAR2(10),
    WebsiteURL                 VARCHAR2(200),
    ValidFrom                  TIMESTAMP      NOT NULL,
    ValidTo                    TIMESTAMP,
    RawRecordKey               NUMBER(12)
);

COMMENT ON TABLE AccountType IS 'Kto prowadzi konto.';
COMMENT ON COLUMN AccountType.AccountTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AccountType.AccountTypeName IS 'Nazwa rodzaju konta';

COMMENT ON TABLE AccountStatus IS 'Stan konta na platformie.';
COMMENT ON COLUMN AccountStatus.AccountStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AccountStatus.AccountStatusName IS 'Nazwa stanu';

COMMENT ON TABLE EmployerAccount IS 'Konto na jednej platformie.';
COMMENT ON COLUMN EmployerAccount.EmployerAccountKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EmployerAccount.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN EmployerAccount.ExternalAccountId IS 'Numer konta w serwisie';
COMMENT ON COLUMN EmployerAccount.AccountTypeKey IS 'Kto prowadzi konto';
COMMENT ON COLUMN EmployerAccount.AccountStatusKey IS 'Stan konta';
COMMENT ON COLUMN EmployerAccount.IsVerifiedByPlatform IS 'Czy platforma sama sprawdziła firmę';
COMMENT ON COLUMN EmployerAccount.FirstSeenAt IS 'Kiedy pierwszy raz dostaliśmy to konto';

COMMENT ON TABLE EmployerAccountVersion IS 'Wersja danych konta – każda zmiana to nowy wiersz.';
COMMENT ON COLUMN EmployerAccountVersion.EmployerAccountVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EmployerAccountVersion.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN EmployerAccountVersion.AccountName IS 'Nazwa konta';
COMMENT ON COLUMN EmployerAccountVersion.DeclaredNIP IS 'NIP wpisany przez właściciela konta (niesprawdzony)';
COMMENT ON COLUMN EmployerAccountVersion.WebsiteURL IS 'Strona www podana w koncie';
COMMENT ON COLUMN EmployerAccountVersion.ValidFrom IS 'Od kiedy dane są takie';
COMMENT ON COLUMN EmployerAccountVersion.ValidTo IS 'Do kiedy (puste = wersja aktualna)';
COMMENT ON COLUMN EmployerAccountVersion.RawRecordKey IS 'Rekord, z którego pochodzi ta wersja';

ALTER TABLE AccountType ADD CONSTRAINT AccountType_PK PRIMARY KEY (AccountTypeKey);
ALTER TABLE AccountType ADD CONSTRAINT AccountType_AccountTypeName_UN UNIQUE (AccountTypeName);
ALTER TABLE AccountStatus ADD CONSTRAINT AccountStatus_PK PRIMARY KEY (AccountStatusKey);
ALTER TABLE AccountStatus ADD CONSTRAINT AccountStatus_AccountStatusName_UN UNIQUE (AccountStatusName);
ALTER TABLE EmployerAccount ADD CONSTRAINT EmployerAccount_PK PRIMARY KEY (EmployerAccountKey);
ALTER TABLE EmployerAccount ADD CONSTRAINT EmployerAccount_UN UNIQUE (SourcePlatformKey, ExternalAccountId);
ALTER TABLE EmployerAccount ADD CONSTRAINT EmployerAccount_IsVerifiedByPlatform_CK CHECK (IsVerifiedByPlatform IN ('T', 'N'));
ALTER TABLE EmployerAccountVersion ADD CONSTRAINT EmployerAccountVersion_PK PRIMARY KEY (EmployerAccountVersionKey);
ALTER TABLE EmployerAccountVersion ADD CONSTRAINT EmployerAccountVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);

ALTER TABLE EmployerAccount ADD CONSTRAINT EmployerAccount_AccountType_FK FOREIGN KEY (AccountTypeKey) REFERENCES AccountType (AccountTypeKey);
ALTER TABLE EmployerAccount ADD CONSTRAINT EmployerAccount_AccountStatus_FK FOREIGN KEY (AccountStatusKey) REFERENCES AccountStatus (AccountStatusKey);
ALTER TABLE EmployerAccountVersion ADD CONSTRAINT EmployerAccountVersion_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES EmployerAccount (EmployerAccountKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO AccountType (AccountTypeKey, AccountTypeName) VALUES (1, 'Firma');
INSERT INTO AccountType (AccountTypeKey, AccountTypeName) VALUES (2, 'Agencja rekrutacyjna');
INSERT INTO AccountType (AccountTypeKey, AccountTypeName) VALUES (3, 'Osoba prywatna');
INSERT INTO AccountType (AccountTypeKey, AccountTypeName) VALUES (4, 'Instytucja publiczna');
INSERT INTO AccountStatus (AccountStatusKey, AccountStatusName) VALUES (1, 'Aktywne');
INSERT INTO AccountStatus (AccountStatusKey, AccountStatusName) VALUES (2, 'Zawieszone przez platformę');
INSERT INTO AccountStatus (AccountStatusKey, AccountStatusName) VALUES (3, 'Usunięte');
COMMIT;
