-- Organizm 1: Platforma źródłowa
-- Skąd w ogóle biorą się dane: serwis z ofertami pracy, jego adresy, kraje i umowa z nami.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE PlatformType (
    PlatformTypeKey   NUMBER(2)     NOT NULL,
    PlatformTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE SourcePlatform (
    SourcePlatformKey   NUMBER(4)      NOT NULL,
    SourcePlatformName  VARCHAR2(50)   NOT NULL,
    MainHomePage        VARCHAR2(100)  NOT NULL,
    PlatformTypeKey     NUMBER(2)      NOT NULL,
    AddedDate           DATE           NOT NULL
);

CREATE TABLE PlatformDomain (
    PlatformDomainKey  NUMBER(5)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    DomainName         VARCHAR2(100)  NOT NULL,
    IsMainDomain       CHAR(1)        NOT NULL
);

CREATE TABLE PlatformMarket (
    PlatformMarketKey  NUMBER(5)  NOT NULL,
    SourcePlatformKey  NUMBER(4)  NOT NULL,
    CountryKey         NUMBER(3)  NOT NULL,
    LaunchDate         DATE
);

CREATE TABLE PartnerAgreement (
    PartnerAgreementKey         NUMBER(5)  NOT NULL,
    SourcePlatformKey           NUMBER(4)  NOT NULL,
    AgreementStatusKey          NUMBER(2)  NOT NULL,
    SignedDate                  DATE,
    ValidFrom                   DATE       NOT NULL,
    ValidTo                     DATE,
    HasDataProcessingAgreement  CHAR(1)    NOT NULL
);

CREATE TABLE AgreementStatus (
    AgreementStatusKey   NUMBER(2)     NOT NULL,
    AgreementStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE Country (
    CountryKey   NUMBER(3)     NOT NULL,
    CountryCode  CHAR(2)       NOT NULL,
    CountryName  VARCHAR2(60)  NOT NULL
);

COMMENT ON TABLE PlatformType IS 'Rodzaj platformy – odpowiedź na pytanie, czym w szerszym kontekście jest źródło ofert.';
COMMENT ON COLUMN PlatformType.PlatformTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PlatformType.PlatformTypeName IS 'Nazwa rodzaju platformy';

COMMENT ON TABLE SourcePlatform IS 'Platforma, z której pochodzą dane, np. pracuj.pl albo OLX – ta sama tabela co na schemacie z zajęć.';
COMMENT ON COLUMN SourcePlatform.SourcePlatformKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SourcePlatform.SourcePlatformName IS 'Nazwa platformy, np. pracuj.pl';
COMMENT ON COLUMN SourcePlatform.MainHomePage IS 'Adres strony głównej';
COMMENT ON COLUMN SourcePlatform.PlatformTypeKey IS 'Rodzaj platformy';
COMMENT ON COLUMN SourcePlatform.AddedDate IS 'Kiedy dodaliśmy platformę jako źródło';

COMMENT ON TABLE PlatformDomain IS 'Adres, pod którym działa platforma. Jedna platforma ma ich kilka.';
COMMENT ON COLUMN PlatformDomain.PlatformDomainKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PlatformDomain.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN PlatformDomain.DomainName IS 'Domena, np. it.pracuj.pl';
COMMENT ON COLUMN PlatformDomain.IsMainDomain IS 'Czy to główny adres platformy';

COMMENT ON TABLE PlatformMarket IS 'Kraj, w którym platforma publikuje oferty – tabela łącząca platformy z krajami.';
COMMENT ON COLUMN PlatformMarket.PlatformMarketKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PlatformMarket.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN PlatformMarket.CountryKey IS 'Kraj';
COMMENT ON COLUMN PlatformMarket.LaunchDate IS 'Od kiedy platforma działa w tym kraju';

COMMENT ON TABLE PartnerAgreement IS 'Umowa o współpracy z platformą. Każda zmiana warunków to nowy wiersz, więc widać całą historię współpracy.';
COMMENT ON COLUMN PartnerAgreement.PartnerAgreementKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PartnerAgreement.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN PartnerAgreement.AgreementStatusKey IS 'Etap umowy';
COMMENT ON COLUMN PartnerAgreement.SignedDate IS 'Data podpisania';
COMMENT ON COLUMN PartnerAgreement.ValidFrom IS 'Od kiedy obowiązuje';
COMMENT ON COLUMN PartnerAgreement.ValidTo IS 'Do kiedy obowiązuje (puste = bez końca)';
COMMENT ON COLUMN PartnerAgreement.HasDataProcessingAgreement IS 'Czy podpisano umowę powierzenia danych osobowych (RODO)';

COMMENT ON TABLE AgreementStatus IS 'Etap umowy z platformą.';
COMMENT ON COLUMN AgreementStatus.AgreementStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AgreementStatus.AgreementStatusName IS 'Nazwa etapu umowy';

COMMENT ON TABLE Country IS 'Kraj – słownik używany też w organizmach 6 i 8.';
COMMENT ON COLUMN Country.CountryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Country.CountryCode IS 'Kod kraju ISO, np. PL';
COMMENT ON COLUMN Country.CountryName IS 'Nazwa kraju';

ALTER TABLE PlatformType ADD CONSTRAINT PlatformType_PK PRIMARY KEY (PlatformTypeKey);
ALTER TABLE PlatformType ADD CONSTRAINT PlatformType_PlatformTypeName_UN UNIQUE (PlatformTypeName);
ALTER TABLE SourcePlatform ADD CONSTRAINT SourcePlatform_PK PRIMARY KEY (SourcePlatformKey);
ALTER TABLE SourcePlatform ADD CONSTRAINT SourcePlatform_SourcePlatformName_UN UNIQUE (SourcePlatformName);
ALTER TABLE PlatformDomain ADD CONSTRAINT PlatformDomain_PK PRIMARY KEY (PlatformDomainKey);
ALTER TABLE PlatformDomain ADD CONSTRAINT PlatformDomain_DomainName_UN UNIQUE (DomainName);
ALTER TABLE PlatformDomain ADD CONSTRAINT PlatformDomain_IsMainDomain_CK CHECK (IsMainDomain IN ('T', 'N'));
ALTER TABLE PlatformMarket ADD CONSTRAINT PlatformMarket_PK PRIMARY KEY (PlatformMarketKey);
ALTER TABLE PlatformMarket ADD CONSTRAINT PlatformMarket_UN UNIQUE (SourcePlatformKey, CountryKey);
ALTER TABLE PartnerAgreement ADD CONSTRAINT PartnerAgreement_PK PRIMARY KEY (PartnerAgreementKey);
ALTER TABLE PartnerAgreement ADD CONSTRAINT PartnerAgreement_HasDataProcessingAgreement_CK CHECK (HasDataProcessingAgreement IN ('T', 'N'));
ALTER TABLE PartnerAgreement ADD CONSTRAINT PartnerAgreement_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE AgreementStatus ADD CONSTRAINT AgreementStatus_PK PRIMARY KEY (AgreementStatusKey);
ALTER TABLE AgreementStatus ADD CONSTRAINT AgreementStatus_AgreementStatusName_UN UNIQUE (AgreementStatusName);
ALTER TABLE Country ADD CONSTRAINT Country_PK PRIMARY KEY (CountryKey);
ALTER TABLE Country ADD CONSTRAINT Country_CountryCode_UN UNIQUE (CountryCode);

ALTER TABLE SourcePlatform ADD CONSTRAINT SourcePlatform_PlatformType_FK FOREIGN KEY (PlatformTypeKey) REFERENCES PlatformType (PlatformTypeKey);
ALTER TABLE PlatformDomain ADD CONSTRAINT PlatformDomain_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES SourcePlatform (SourcePlatformKey);
ALTER TABLE PlatformMarket ADD CONSTRAINT PlatformMarket_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES SourcePlatform (SourcePlatformKey);
ALTER TABLE PlatformMarket ADD CONSTRAINT PlatformMarket_Country_FK FOREIGN KEY (CountryKey) REFERENCES Country (CountryKey);
ALTER TABLE PartnerAgreement ADD CONSTRAINT PartnerAgreement_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES SourcePlatform (SourcePlatformKey);
ALTER TABLE PartnerAgreement ADD CONSTRAINT PartnerAgreement_AgreementStatus_FK FOREIGN KEY (AgreementStatusKey) REFERENCES AgreementStatus (AgreementStatusKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (1, 'Portal z ofertami pracy');
INSERT INTO PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (2, 'Serwis ogłoszeń drobnych');
INSERT INTO PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (3, 'Agregator ofert');
INSERT INTO PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (4, 'Serwis społecznościowy');
INSERT INTO PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (5, 'Publiczny urząd pracy');
INSERT INTO PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (6, 'Strona kariery firmy (ATS)');
INSERT INTO SourcePlatform (SourcePlatformKey, SourcePlatformName, MainHomePage, PlatformTypeKey, AddedDate) VALUES (1, 'pracuj.pl', 'https://www.pracuj.pl', 1, DATE '2026-10-01');
INSERT INTO SourcePlatform (SourcePlatformKey, SourcePlatformName, MainHomePage, PlatformTypeKey, AddedDate) VALUES (2, 'OLX', 'https://www.olx.pl', 2, DATE '2026-10-01');
INSERT INTO Country (CountryKey, CountryCode, CountryName) VALUES (1, 'PL', 'Polska');
INSERT INTO Country (CountryKey, CountryCode, CountryName) VALUES (2, 'DE', 'Niemcy');
INSERT INTO Country (CountryKey, CountryCode, CountryName) VALUES (3, 'CZ', 'Czechy');
INSERT INTO Country (CountryKey, CountryCode, CountryName) VALUES (4, 'RO', 'Rumunia');
INSERT INTO Country (CountryKey, CountryCode, CountryName) VALUES (5, 'PT', 'Portugalia');
INSERT INTO Country (CountryKey, CountryCode, CountryName) VALUES (6, 'UA', 'Ukraina');
INSERT INTO AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (1, 'Negocjacje');
INSERT INTO AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (2, 'Pilotaż');
INSERT INTO AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (3, 'Aktywna');
INSERT INTO AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (4, 'Zawieszona');
INSERT INTO AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (5, 'Rozwiązana');
COMMIT;
