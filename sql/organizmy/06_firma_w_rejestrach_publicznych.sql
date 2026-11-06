-- Organizm 6: Firma w rejestrach publicznych
-- Podmiot prawny stojący za ogłoszeniami, sprawdzony w rejestrach państwowych.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG06_LegalForm (
    LegalFormKey        NUMBER(2)     NOT NULL,
    LegalFormName       VARCHAR2(60)  NOT NULL,
    LegalFormShortName  VARCHAR2(20),
    LegalFormCode       CHAR(3)
);

CREATE TABLE ORG06_PKDClassification (
    PKDClassificationKey   NUMBER(1)     NOT NULL,
    PKDClassificationName  VARCHAR2(20)  NOT NULL,
    ValidFrom              DATE          NOT NULL
);

CREATE TABLE ORG06_PKDCode (
    PKDCodeKey            NUMBER(4)      NOT NULL,
    PKDSymbol             VARCHAR2(7)    NOT NULL,
    PKDName               VARCHAR2(250)  NOT NULL,
    PKDClassificationKey  NUMBER(1)      NOT NULL
);

CREATE TABLE ORG06_EmployerIdentifier (
    EmployerIdentifierKey  NUMBER(8)     NOT NULL,
    EmployerKey            NUMBER(7)     NOT NULL,
    IdentifierTypeKey      NUMBER(2)     NOT NULL,
    IdentifierValue        VARCHAR2(30)  NOT NULL,
    IsChecksumValid        NUMBER(1)     NOT NULL
);

CREATE TABLE ORG06_Employer (
    EmployerKey        NUMBER(7)      NOT NULL,
    OfficialName       VARCHAR2(250)  NOT NULL,
    LegalFormKey       NUMBER(2)      NOT NULL,
    CountryKey         NUMBER(3)      NOT NULL,
    EmployerStatusKey  NUMBER(2)      NOT NULL,
    RegistrationDate   DATE
);

CREATE TABLE ORG06_EmployerPKD (
    EmployerPKDKey  NUMBER(8)  NOT NULL,
    EmployerKey     NUMBER(7)  NOT NULL,
    PKDCodeKey      NUMBER(4)  NOT NULL,
    IsMainActivity  NUMBER(1)  NOT NULL,
    ValidFrom       DATE,
    ValidTo         DATE,
    IsCurrent       NUMBER(1)  NOT NULL
);

CREATE TABLE ORG06_IdentifierType (
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    IdentifierTypeName  VARCHAR2(40)  NOT NULL,
    ValueFormat         VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG06_RegistryCheck (
    RegistryCheckKey   NUMBER(9)      NOT NULL,
    EmployerKey        NUMBER(7)      NOT NULL,
    PublicRegistryKey  NUMBER(2)      NOT NULL,
    CheckedAt          TIMESTAMP      NOT NULL,
    WasFound           NUMBER(1)      NOT NULL,
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
COMMENT ON COLUMN ORG06_LegalForm.LegalFormCode IS 'Kod szczególnej formy prawnej z rejestru REGON, np. 117 – tekst, bo kody zaczynają się od zera (019, 048, 099)';

COMMENT ON TABLE ORG06_PKDClassification IS 'Wersja klasyfikacji PKD – wybierana z listy, a nie wpisywana.';
COMMENT ON COLUMN ORG06_PKDClassification.PKDClassificationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PKDClassification.PKDClassificationName IS 'Nazwa klasyfikacji';
COMMENT ON COLUMN ORG06_PKDClassification.ValidFrom IS 'Od kiedy obowiązuje';

COMMENT ON TABLE ORG06_PKDCode IS 'Rodzaj działalności z klasyfikacji PKD.';
COMMENT ON COLUMN ORG06_PKDCode.PKDCodeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PKDCode.PKDSymbol IS 'Symbol, np. 52.10.B';
COMMENT ON COLUMN ORG06_PKDCode.PKDName IS 'Nazwa działalności';
COMMENT ON COLUMN ORG06_PKDCode.PKDClassificationKey IS 'Wersja klasyfikacji';

COMMENT ON TABLE ORG06_EmployerIdentifier IS 'Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerIdentifierKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierTypeKey IS 'Rodzaj numeru';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierValue IS 'Numer – tekst, bo może zaczynać się od zera';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IsChecksumValid IS '1 = numer przeszedł kontrolę sumy kontrolnej';

COMMENT ON TABLE ORG06_Employer IS 'Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust Score.';
COMMENT ON COLUMN ORG06_Employer.EmployerKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_Employer.OfficialName IS 'Nazwa urzędowa';
COMMENT ON COLUMN ORG06_Employer.LegalFormKey IS 'Forma prawna';
COMMENT ON COLUMN ORG06_Employer.CountryKey IS 'Kraj rejestracji';
COMMENT ON COLUMN ORG06_Employer.EmployerStatusKey IS 'Aktualny status';
COMMENT ON COLUMN ORG06_Employer.RegistrationDate IS 'Data wpisu do rejestru';

COMMENT ON TABLE ORG06_EmployerPKD IS 'Rodzaj działalności firmy – przypisanie w czasie firmy do kodu PKD.';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerPKDKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerPKD.PKDCodeKey IS 'Kod PKD';
COMMENT ON COLUMN ORG06_EmployerPKD.IsMainActivity IS '1 = działalność główna';
COMMENT ON COLUMN ORG06_EmployerPKD.ValidFrom IS 'Od kiedy firma prowadzi tę działalność (puste = nie wiemy)';
COMMENT ON COLUMN ORG06_EmployerPKD.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG06_EmployerPKD.IsCurrent IS '1 = działalność prowadzona teraz';

COMMENT ON TABLE ORG06_IdentifierType IS 'Rodzaj numeru identyfikacyjnego.';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeName IS 'Nazwa rodzaju numeru';
COMMENT ON COLUMN ORG06_IdentifierType.ValueFormat IS 'Jak wygląda poprawny numer';

COMMENT ON TABLE ORG06_RegistryCheck IS 'Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.';
COMMENT ON COLUMN ORG06_RegistryCheck.RegistryCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_RegistryCheck.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_RegistryCheck.PublicRegistryKey IS 'Rejestr';
COMMENT ON COLUMN ORG06_RegistryCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ORG06_RegistryCheck.WasFound IS '1 = rejestr znalazł firmę';
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
ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_LegalFormCode_UN UNIQUE (LegalFormCode);
ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_CK1 CHECK (REGEXP_LIKE(LegalFormCode, '^[0-9]{3}$'));
ALTER TABLE ORG06_PKDClassification ADD CONSTRAINT ORG06_PKDClassification_PK PRIMARY KEY (PKDClassificationKey);
ALTER TABLE ORG06_PKDClassification ADD CONSTRAINT ORG06_PKDClassification_PKDClassificationName_UN UNIQUE (PKDClassificationName);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_PK PRIMARY KEY (PKDCodeKey);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_UN UNIQUE (PKDSymbol, PKDClassificationKey);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_CK1 CHECK (REGEXP_LIKE(PKDSymbol, '^[0-9]{2}\.[0-9]{2}\.[A-Z]$'));
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_PK PRIMARY KEY (EmployerIdentifierKey);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_UN UNIQUE (IdentifierTypeKey, IdentifierValue);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_IsChecksumValid_CK CHECK (IsChecksumValid IN (0, 1));
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_PK PRIMARY KEY (EmployerKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_PK PRIMARY KEY (EmployerPKDKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_IsMainActivity_CK CHECK (IsMainActivity IN (0, 1));
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_PK PRIMARY KEY (IdentifierTypeKey);
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_IdentifierTypeName_UN UNIQUE (IdentifierTypeName);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_PK PRIMARY KEY (RegistryCheckKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_WasFound_CK CHECK (WasFound IN (0, 1));
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_PK PRIMARY KEY (EmployerStatusKey);
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_EmployerStatusName_UN UNIQUE (EmployerStatusName);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PK PRIMARY KEY (PublicRegistryKey);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PublicRegistryName_UN UNIQUE (PublicRegistryName);

ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_PKDClassification_FK FOREIGN KEY (PKDClassificationKey) REFERENCES ORG06_PKDClassification (PKDClassificationKey);
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

-- Unikalne tylko w części wierszy, np. jeden aktualny wiersz (unikalny indeks funkcyjny).
CREATE UNIQUE INDEX ORG06_EmployerPKD_UX1 ON ORG06_EmployerPKD (CASE WHEN IsCurrent = 1 THEN EmployerKey END, CASE WHEN IsCurrent = 1 THEN PKDCodeKey END);
CREATE UNIQUE INDEX ORG06_EmployerPKD_UX2 ON ORG06_EmployerPKD (CASE WHEN IsCurrent = 1 AND IsMainActivity = 1 THEN EmployerKey END);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (1, 'Spółka z ograniczoną odpowiedzialnością', 'sp. z o.o.', '117');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (2, 'Spółka akcyjna', 'S.A.', '116');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (3, 'Jednoosobowa działalność gospodarcza', 'JDG', '099');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (4, 'Spółka cywilna', 's.c.', '019');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (5, 'Spółka jawna', 'sp.j.', '118');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (6, 'Fundacja', NULL, '048');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (7, 'Stowarzyszenie', NULL, '155');
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (8, 'Jednostka sektora publicznego', NULL, NULL);
INSERT INTO ORG06_LegalForm (LegalFormKey, LegalFormName, LegalFormShortName, LegalFormCode) VALUES (9, 'Firma zagraniczna', NULL, NULL);
INSERT INTO ORG06_PKDClassification (PKDClassificationKey, PKDClassificationName, ValidFrom) VALUES (1, 'PKD 2007', DATE '2008-01-01');
INSERT INTO ORG06_PKDClassification (PKDClassificationKey, PKDClassificationName, ValidFrom) VALUES (2, 'PKD 2025', DATE '2025-01-01');
INSERT INTO ORG06_EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (1, 'Aktywna');
INSERT INTO ORG06_EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (2, 'Zawieszona');
INSERT INTO ORG06_EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (3, 'W likwidacji');
INSERT INTO ORG06_EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (4, 'W upadłości');
INSERT INTO ORG06_EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (5, 'Wykreślona');
INSERT INTO ORG06_EmployerStatus (EmployerStatusKey, EmployerStatusName) VALUES (6, 'Nieznaleziona w rejestrze');
INSERT INTO ORG06_IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (1, 'NIP', '10 cyfr, ostatnia to suma kontrolna');
INSERT INTO ORG06_IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (2, 'REGON', '9 albo 14 cyfr');
INSERT INTO ORG06_IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (3, 'KRS', '10 cyfr');
INSERT INTO ORG06_IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (4, 'Numer VAT UE', 'kod kraju i numer');
INSERT INTO ORG06_IdentifierType (IdentifierTypeKey, IdentifierTypeName, ValueFormat) VALUES (5, 'Zagraniczny numer rejestrowy', 'dowolny');
INSERT INTO ORG06_PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (1, 'Krajowy Rejestr Sądowy (KRS)', 3, NULL);
INSERT INTO ORG06_PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (2, 'CEIDG', 1, NULL);
INSERT INTO ORG06_PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (3, 'Rejestr REGON (GUS)', 2, NULL);
INSERT INTO ORG06_PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (4, 'Biała lista podatników VAT', 1, NULL);
INSERT INTO ORG06_PublicRegistry (PublicRegistryKey, PublicRegistryName, IdentifierTypeKey, DailyQueryLimit) VALUES (5, 'VIES – rejestr VAT UE', 4, NULL);
COMMIT;
