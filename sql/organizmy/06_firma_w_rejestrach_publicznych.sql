-- Organizm 6: Firma w rejestrach publicznych
-- Podmiot prawny stojący za ogłoszeniami, sprawdzony w rejestrach państwowych.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE LegalForm (
    LegalFormKey        NUMBER(2)     NOT NULL,
    LegalFormName       VARCHAR2(60)  NOT NULL,
    LegalFormShortName  VARCHAR2(20)
);

CREATE TABLE PKDCode (
    PKDCodeKey             NUMBER(4)      NOT NULL,
    PKDSymbol              VARCHAR2(7)    NOT NULL,
    PKDName                VARCHAR2(250)  NOT NULL,
    ClassificationVersion  VARCHAR2(10)   NOT NULL
);

CREATE TABLE EmployerIdentifier (
    EmployerIdentifierKey  NUMBER(9)     NOT NULL,
    EmployerKey            NUMBER(8)     NOT NULL,
    IdentifierTypeKey      NUMBER(2)     NOT NULL,
    IdentifierValue        VARCHAR2(30)  NOT NULL,
    IsChecksumValid        CHAR(1)       NOT NULL
);

CREATE TABLE Employer (
    EmployerKey        NUMBER(8)      NOT NULL,
    OfficialName       VARCHAR2(250)  NOT NULL,
    LegalFormKey       NUMBER(2)      NOT NULL,
    CountryKey         NUMBER(3)      NOT NULL,
    EmployerStatusKey  NUMBER(2)      NOT NULL,
    RegistrationDate   DATE
);

CREATE TABLE EmployerPKD (
    EmployerPKDKey  NUMBER(9)  NOT NULL,
    EmployerKey     NUMBER(8)  NOT NULL,
    PKDCodeKey      NUMBER(4)  NOT NULL,
    IsMainActivity  CHAR(1)    NOT NULL
);

CREATE TABLE IdentifierType (
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    IdentifierTypeName  VARCHAR2(40)  NOT NULL,
    ValueFormat         VARCHAR2(60)  NOT NULL
);

CREATE TABLE RegistryCheck (
    RegistryCheckKey   NUMBER(10)     NOT NULL,
    EmployerKey        NUMBER(8)      NOT NULL,
    PublicRegistryKey  NUMBER(2)      NOT NULL,
    CheckedAt          TIMESTAMP      NOT NULL,
    WasFound           CHAR(1)        NOT NULL,
    ReportedStatusKey  NUMBER(2),
    ReportedName       VARCHAR2(250)
);

CREATE TABLE EmployerStatus (
    EmployerStatusKey   NUMBER(2)     NOT NULL,
    EmployerStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE PublicRegistry (
    PublicRegistryKey   NUMBER(2)     NOT NULL,
    PublicRegistryName  VARCHAR2(60)  NOT NULL,
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    DailyQueryLimit     NUMBER(7)
);

COMMENT ON TABLE LegalForm IS 'Forma prawna podmiotu.';
COMMENT ON COLUMN LegalForm.LegalFormKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN LegalForm.LegalFormName IS 'Pełna nazwa formy prawnej';
COMMENT ON COLUMN LegalForm.LegalFormShortName IS 'Skrót, np. sp. z o.o.';

COMMENT ON TABLE PKDCode IS 'Rodzaj działalności z klasyfikacji PKD.';
COMMENT ON COLUMN PKDCode.PKDCodeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PKDCode.PKDSymbol IS 'Symbol, np. 78.10.Z';
COMMENT ON COLUMN PKDCode.PKDName IS 'Nazwa działalności';
COMMENT ON COLUMN PKDCode.ClassificationVersion IS 'Wersja klasyfikacji, np. PKD 2007 albo PKD 2025';

COMMENT ON TABLE EmployerIdentifier IS 'Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.';
COMMENT ON COLUMN EmployerIdentifier.EmployerIdentifierKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EmployerIdentifier.EmployerKey IS 'Firma';
COMMENT ON COLUMN EmployerIdentifier.IdentifierTypeKey IS 'Rodzaj numeru';
COMMENT ON COLUMN EmployerIdentifier.IdentifierValue IS 'Numer';
COMMENT ON COLUMN EmployerIdentifier.IsChecksumValid IS 'Czy numer przeszedł kontrolę sumy kontrolnej';

COMMENT ON TABLE Employer IS 'Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust Score.';
COMMENT ON COLUMN Employer.EmployerKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Employer.OfficialName IS 'Nazwa urzędowa';
COMMENT ON COLUMN Employer.LegalFormKey IS 'Forma prawna';
COMMENT ON COLUMN Employer.CountryKey IS 'Kraj rejestracji';
COMMENT ON COLUMN Employer.EmployerStatusKey IS 'Aktualny status';
COMMENT ON COLUMN Employer.RegistrationDate IS 'Data wpisu do rejestru';

COMMENT ON TABLE EmployerPKD IS 'Rodzaj działalności firmy – tabela łącząca firmy z kodami PKD.';
COMMENT ON COLUMN EmployerPKD.EmployerPKDKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EmployerPKD.EmployerKey IS 'Firma';
COMMENT ON COLUMN EmployerPKD.PKDCodeKey IS 'Kod PKD';
COMMENT ON COLUMN EmployerPKD.IsMainActivity IS 'Czy to działalność główna';

COMMENT ON TABLE IdentifierType IS 'Rodzaj numeru identyfikacyjnego.';
COMMENT ON COLUMN IdentifierType.IdentifierTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN IdentifierType.IdentifierTypeName IS 'Nazwa rodzaju numeru';
COMMENT ON COLUMN IdentifierType.ValueFormat IS 'Jak wygląda poprawny numer';

COMMENT ON TABLE RegistryCheck IS 'Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.';
COMMENT ON COLUMN RegistryCheck.RegistryCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN RegistryCheck.EmployerKey IS 'Firma';
COMMENT ON COLUMN RegistryCheck.PublicRegistryKey IS 'Rejestr';
COMMENT ON COLUMN RegistryCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN RegistryCheck.WasFound IS 'Czy rejestr znalazł firmę';
COMMENT ON COLUMN RegistryCheck.ReportedStatusKey IS 'Status podany przez rejestr';
COMMENT ON COLUMN RegistryCheck.ReportedName IS 'Nazwa podana przez rejestr';

COMMENT ON TABLE EmployerStatus IS 'Status firmy w rejestrze.';
COMMENT ON COLUMN EmployerStatus.EmployerStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EmployerStatus.EmployerStatusName IS 'Nazwa statusu';

COMMENT ON TABLE PublicRegistry IS 'Rejestr państwowy, w którym sprawdzamy firmy.';
COMMENT ON COLUMN PublicRegistry.PublicRegistryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PublicRegistry.PublicRegistryName IS 'Nazwa rejestru';
COMMENT ON COLUMN PublicRegistry.IdentifierTypeKey IS 'Po jakim numerze pytamy rejestr';
COMMENT ON COLUMN PublicRegistry.DailyQueryLimit IS 'Ile zapytań dziennie pozwala rejestr';

ALTER TABLE LegalForm ADD CONSTRAINT LegalForm_PK PRIMARY KEY (LegalFormKey);
ALTER TABLE LegalForm ADD CONSTRAINT LegalForm_LegalFormName_UN UNIQUE (LegalFormName);
ALTER TABLE PKDCode ADD CONSTRAINT PKDCode_PK PRIMARY KEY (PKDCodeKey);
ALTER TABLE PKDCode ADD CONSTRAINT PKDCode_UN UNIQUE (PKDSymbol, ClassificationVersion);
ALTER TABLE EmployerIdentifier ADD CONSTRAINT EmployerIdentifier_PK PRIMARY KEY (EmployerIdentifierKey);
ALTER TABLE EmployerIdentifier ADD CONSTRAINT EmployerIdentifier_UN UNIQUE (IdentifierTypeKey, IdentifierValue);
ALTER TABLE EmployerIdentifier ADD CONSTRAINT EmployerIdentifier_IsChecksumValid_CK CHECK (IsChecksumValid IN ('T', 'N'));
ALTER TABLE Employer ADD CONSTRAINT Employer_PK PRIMARY KEY (EmployerKey);
ALTER TABLE EmployerPKD ADD CONSTRAINT EmployerPKD_PK PRIMARY KEY (EmployerPKDKey);
ALTER TABLE EmployerPKD ADD CONSTRAINT EmployerPKD_UN UNIQUE (EmployerKey, PKDCodeKey);
ALTER TABLE EmployerPKD ADD CONSTRAINT EmployerPKD_IsMainActivity_CK CHECK (IsMainActivity IN ('T', 'N'));
ALTER TABLE IdentifierType ADD CONSTRAINT IdentifierType_PK PRIMARY KEY (IdentifierTypeKey);
ALTER TABLE IdentifierType ADD CONSTRAINT IdentifierType_IdentifierTypeName_UN UNIQUE (IdentifierTypeName);
ALTER TABLE RegistryCheck ADD CONSTRAINT RegistryCheck_PK PRIMARY KEY (RegistryCheckKey);
ALTER TABLE RegistryCheck ADD CONSTRAINT RegistryCheck_WasFound_CK CHECK (WasFound IN ('T', 'N'));
ALTER TABLE EmployerStatus ADD CONSTRAINT EmployerStatus_PK PRIMARY KEY (EmployerStatusKey);
ALTER TABLE EmployerStatus ADD CONSTRAINT EmployerStatus_EmployerStatusName_UN UNIQUE (EmployerStatusName);
ALTER TABLE PublicRegistry ADD CONSTRAINT PublicRegistry_PK PRIMARY KEY (PublicRegistryKey);
ALTER TABLE PublicRegistry ADD CONSTRAINT PublicRegistry_PublicRegistryName_UN UNIQUE (PublicRegistryName);

ALTER TABLE EmployerIdentifier ADD CONSTRAINT EmployerIdentifier_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);
ALTER TABLE EmployerIdentifier ADD CONSTRAINT EmployerIdentifier_IdentifierType_FK FOREIGN KEY (IdentifierTypeKey) REFERENCES IdentifierType (IdentifierTypeKey);
ALTER TABLE Employer ADD CONSTRAINT Employer_LegalForm_FK FOREIGN KEY (LegalFormKey) REFERENCES LegalForm (LegalFormKey);
ALTER TABLE Employer ADD CONSTRAINT Employer_EmployerStatus_FK FOREIGN KEY (EmployerStatusKey) REFERENCES EmployerStatus (EmployerStatusKey);
ALTER TABLE EmployerPKD ADD CONSTRAINT EmployerPKD_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);
ALTER TABLE EmployerPKD ADD CONSTRAINT EmployerPKD_PKDCode_FK FOREIGN KEY (PKDCodeKey) REFERENCES PKDCode (PKDCodeKey);
ALTER TABLE RegistryCheck ADD CONSTRAINT RegistryCheck_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES Employer (EmployerKey);
ALTER TABLE RegistryCheck ADD CONSTRAINT RegistryCheck_PublicRegistry_FK FOREIGN KEY (PublicRegistryKey) REFERENCES PublicRegistry (PublicRegistryKey);
ALTER TABLE RegistryCheck ADD CONSTRAINT RegistryCheck_EmployerStatus_FK FOREIGN KEY (ReportedStatusKey) REFERENCES EmployerStatus (EmployerStatusKey);
ALTER TABLE PublicRegistry ADD CONSTRAINT PublicRegistry_IdentifierType_FK FOREIGN KEY (IdentifierTypeKey) REFERENCES IdentifierType (IdentifierTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (1, 'Spółka z ograniczoną odpowiedzialnością', 'sp. z o.o.');
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (2, 'Spółka akcyjna', 'S.A.');
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (3, 'Jednoosobowa działalność gospodarcza', 'JDG');
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (4, 'Spółka cywilna', 's.c.');
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (5, 'Spółka jawna', 'sp.j.');
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (6, 'Fundacja', NULL);
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (7, 'Stowarzyszenie', NULL);
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (8, 'Jednostka sektora publicznego', NULL);
INSERT INTO LegalForm (LegalFormKey, LegalFormName, LegalFormShortName) VALUES (9, 'Firma zagraniczna', NULL);
INSERT INTO EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (1, 'Aktywna');
INSERT INTO EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (2, 'Zawieszona');
INSERT INTO EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (3, 'W likwidacji');
INSERT INTO EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (4, 'W upadłości');
INSERT INTO EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (5, 'Wykreślona');
INSERT INTO EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (6, 'Nieznaleziona w rejestrze');
INSERT INTO IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (1, 'NIP', '10 cyfr, ostatnia to suma kontrolna');
INSERT INTO IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (2, 'REGON', '9 albo 14 cyfr');
INSERT INTO IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (3, 'KRS', '10 cyfr');
INSERT INTO IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (4, 'Numer VAT UE', 'kod kraju i numer');
INSERT INTO IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (5, 'Zagraniczny numer rejestrowy', 'dowolny');
INSERT INTO PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (1, 'Krajowy Rejestr Sądowy (KRS)', 3, NULL);
INSERT INTO PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (2, 'CEIDG', 1, NULL);
INSERT INTO PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (3, 'Rejestr REGON (GUS)', 2, NULL);
INSERT INTO PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (4, 'Biała lista podatników VAT', 1, NULL);
INSERT INTO PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (5, 'VIES – rejestr VAT UE', 4, NULL);
COMMIT;
