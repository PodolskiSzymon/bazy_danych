-- Organizm 6: Firma w rejestrach publicznych
-- Podmiot prawny stojący za ogłoszeniami, sprawdzony w rejestrach państwowych.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG06_LegalForm (
    LegalFormKey        NUMBER(2)     NOT NULL,
    LegalFormName       VARCHAR2(60)  NOT NULL,
    LegalFormShortName  VARCHAR2(20)
);

CREATE TABLE ORG06_PKDCode (
    PKDCodeKey             NUMBER(4)      NOT NULL,
    PKDSymbol              VARCHAR2(7)    NOT NULL,
    PKDName                VARCHAR2(250)  NOT NULL,
    ClassificationVersion  VARCHAR2(10)   NOT NULL
);

CREATE TABLE ORG06_EmployerIdentifier (
    EmployerIdentifierKey  NUMBER(9)     NOT NULL,
    EmployerKey            NUMBER(8)     NOT NULL,
    IdentifierTypeKey      NUMBER(2)     NOT NULL,
    IdentifierValue        VARCHAR2(30)  NOT NULL,
    IsChecksumValid        CHAR(1)       NOT NULL
);

CREATE TABLE ORG06_Employer (
    EmployerKey        NUMBER(8)      NOT NULL,
    OfficialName       VARCHAR2(250)  NOT NULL,
    LegalFormKey       NUMBER(2)      NOT NULL,
    CountryKey         NUMBER(3)      NOT NULL,
    EmployerStatusKey  NUMBER(2)      NOT NULL,
    RegistrationDate   DATE
);

CREATE TABLE ORG06_EmployerPKD (
    EmployerPKDKey  NUMBER(9)  NOT NULL,
    EmployerKey     NUMBER(8)  NOT NULL,
    PKDCodeKey      NUMBER(4)  NOT NULL,
    IsMainActivity  CHAR(1)    NOT NULL
);

CREATE TABLE ORG06_IdentifierType (
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    IdentifierTypeName  VARCHAR2(40)  NOT NULL,
    ValueFormat         VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG06_RegistryCheck (
    RegistryCheckKey   NUMBER(10)     NOT NULL,
    EmployerKey        NUMBER(8)      NOT NULL,
    PublicRegistryKey  NUMBER(2)      NOT NULL,
    CheckedAt          TIMESTAMP      NOT NULL,
    WasFound           CHAR(1)        NOT NULL,
    ReportedStatusKey  NUMBER(2),
    ReportedName       VARCHAR2(250)
);

CREATE TABLE ORG06_EmployerStatus (
    EmployerStatusKey   NUMBER(2)     NOT NULL,
    EmployerStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG06_PublicRegistry (
    PublicRegistryKey   NUMBER(2)     NOT NULL,
    PublicRegistryName  VARCHAR2(60)  NOT NULL,
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    DailyQueryLimit     NUMBER(7)
);

COMMENT ON TABLE ORG06_LegalForm IS 'Forma prawna podmiotu.';
COMMENT ON COLUMN ORG06_LegalForm.LegalFormKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_LegalForm.LegalFormName IS 'Pełna nazwa formy prawnej';
COMMENT ON COLUMN ORG06_LegalForm.LegalFormShortName IS 'Skrót, np. sp. z o.o.';

COMMENT ON TABLE ORG06_PKDCode IS 'Rodzaj działalności z klasyfikacji PKD.';
COMMENT ON COLUMN ORG06_PKDCode.PKDCodeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PKDCode.PKDSymbol IS 'Symbol, np. 78.10.Z';
COMMENT ON COLUMN ORG06_PKDCode.PKDName IS 'Nazwa działalności';
COMMENT ON COLUMN ORG06_PKDCode.ClassificationVersion IS 'Wersja klasyfikacji, np. PKD 2007 albo PKD 2025';

COMMENT ON TABLE ORG06_EmployerIdentifier IS 'Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerIdentifierKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierTypeKey IS 'Rodzaj numeru';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierValue IS 'Numer';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IsChecksumValid IS 'Czy numer przeszedł kontrolę sumy kontrolnej';

COMMENT ON TABLE ORG06_Employer IS 'Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust Score.';
COMMENT ON COLUMN ORG06_Employer.EmployerKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_Employer.OfficialName IS 'Nazwa urzędowa';
COMMENT ON COLUMN ORG06_Employer.LegalFormKey IS 'Forma prawna';
COMMENT ON COLUMN ORG06_Employer.CountryKey IS 'Kraj rejestracji';
COMMENT ON COLUMN ORG06_Employer.EmployerStatusKey IS 'Aktualny status';
COMMENT ON COLUMN ORG06_Employer.RegistrationDate IS 'Data wpisu do rejestru';

COMMENT ON TABLE ORG06_EmployerPKD IS 'Rodzaj działalności firmy – tabela łącząca firmy z kodami PKD.';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerPKDKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerPKD.PKDCodeKey IS 'Kod PKD';
COMMENT ON COLUMN ORG06_EmployerPKD.IsMainActivity IS 'Czy to działalność główna';

COMMENT ON TABLE ORG06_IdentifierType IS 'Rodzaj numeru identyfikacyjnego.';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeName IS 'Nazwa rodzaju numeru';
COMMENT ON COLUMN ORG06_IdentifierType.ValueFormat IS 'Jak wygląda poprawny numer';

COMMENT ON TABLE ORG06_RegistryCheck IS 'Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.';
COMMENT ON COLUMN ORG06_RegistryCheck.RegistryCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_RegistryCheck.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_RegistryCheck.PublicRegistryKey IS 'Rejestr';
COMMENT ON COLUMN ORG06_RegistryCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ORG06_RegistryCheck.WasFound IS 'Czy rejestr znalazł firmę';
COMMENT ON COLUMN ORG06_RegistryCheck.ReportedStatusKey IS 'Status podany przez rejestr';
COMMENT ON COLUMN ORG06_RegistryCheck.ReportedName IS 'Nazwa podana przez rejestr';

COMMENT ON TABLE ORG06_EmployerStatus IS 'Status firmy w rejestrze.';
COMMENT ON COLUMN ORG06_EmployerStatus.EmployerStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerStatus.EmployerStatusName IS 'Nazwa statusu';

COMMENT ON TABLE ORG06_PublicRegistry IS 'Rejestr państwowy, w którym sprawdzamy firmy.';
COMMENT ON COLUMN ORG06_PublicRegistry.PublicRegistryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PublicRegistry.PublicRegistryName IS 'Nazwa rejestru';
COMMENT ON COLUMN ORG06_PublicRegistry.IdentifierTypeKey IS 'Po jakim numerze pytamy rejestr';
COMMENT ON COLUMN ORG06_PublicRegistry.DailyQueryLimit IS 'Ile zapytań dziennie pozwala rejestr';

ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_PK PRIMARY KEY (LegalFormKey);
ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_LegalFormName_UN UNIQUE (LegalFormName);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_PK PRIMARY KEY (PKDCodeKey);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_UN UNIQUE (PKDSymbol, ClassificationVersion);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_PK PRIMARY KEY (EmployerIdentifierKey);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_UN UNIQUE (IdentifierTypeKey, IdentifierValue);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_IsChecksumValid_CK CHECK (IsChecksumValid IN ('T', 'N'));
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_PK PRIMARY KEY (EmployerKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_PK PRIMARY KEY (EmployerPKDKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_UN UNIQUE (EmployerKey, PKDCodeKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_IsMainActivity_CK CHECK (IsMainActivity IN ('T', 'N'));
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_PK PRIMARY KEY (IdentifierTypeKey);
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_IdentifierTypeName_UN UNIQUE (IdentifierTypeName);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_PK PRIMARY KEY (RegistryCheckKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_WasFound_CK CHECK (WasFound IN ('T', 'N'));
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_PK PRIMARY KEY (EmployerStatusKey);
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_EmployerStatusName_UN UNIQUE (EmployerStatusName);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PK PRIMARY KEY (PublicRegistryKey);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PublicRegistryName_UN UNIQUE (PublicRegistryName);

ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_IdentifierType_FK FOREIGN KEY (IdentifierTypeKey) REFERENCES ORG06_IdentifierType (IdentifierTypeKey);
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_LegalForm_FK FOREIGN KEY (LegalFormKey) REFERENCES ORG06_LegalForm (LegalFormKey);
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_EmployerStatus_FK FOREIGN KEY (EmployerStatusKey) REFERENCES ORG06_EmployerStatus (EmployerStatusKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_PKDCode_FK FOREIGN KEY (PKDCodeKey) REFERENCES ORG06_PKDCode (PKDCodeKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_PublicRegistry_FK FOREIGN KEY (PublicRegistryKey) REFERENCES ORG06_PublicRegistry (PublicRegistryKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_EmployerStatus_FK FOREIGN KEY (ReportedStatusKey) REFERENCES ORG06_EmployerStatus (EmployerStatusKey);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_IdentifierType_FK FOREIGN KEY (IdentifierTypeKey) REFERENCES ORG06_IdentifierType (IdentifierTypeKey);
