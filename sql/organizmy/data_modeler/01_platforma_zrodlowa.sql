-- Organizm 1: Platforma źródłowa
-- Skąd w ogóle biorą się dane: serwis z ofertami pracy, jego adresy, kraje i umowa z nami.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG01_PlatformType (
    PlatformTypeKey   NUMBER(2)     NOT NULL,
    PlatformTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG01_SourcePlatform (
    SourcePlatformKey   NUMBER(4)      NOT NULL,
    SourcePlatformName  VARCHAR2(50)   NOT NULL,
    MainHomePage        VARCHAR2(100)  NOT NULL,
    PlatformTypeKey     NUMBER(2)      NOT NULL,
    AddedDate           DATE           NOT NULL
);

CREATE TABLE ORG01_PlatformDomain (
    PlatformDomainKey  NUMBER(5)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    DomainName         VARCHAR2(100)  NOT NULL,
    IsMainDomain       CHAR(1)        NOT NULL
);

CREATE TABLE ORG01_PlatformMarket (
    PlatformMarketKey  NUMBER(5)  NOT NULL,
    SourcePlatformKey  NUMBER(4)  NOT NULL,
    CountryKey         NUMBER(3)  NOT NULL,
    LaunchDate         DATE
);

CREATE TABLE ORG01_PartnerAgreement (
    PartnerAgreementKey         NUMBER(5)  NOT NULL,
    SourcePlatformKey           NUMBER(4)  NOT NULL,
    AgreementStatusKey          NUMBER(2)  NOT NULL,
    SignedDate                  DATE,
    ValidFrom                   DATE       NOT NULL,
    ValidTo                     DATE,
    HasDataProcessingAgreement  CHAR(1)    NOT NULL
);

CREATE TABLE ORG01_AgreementStatus (
    AgreementStatusKey   NUMBER(2)     NOT NULL,
    AgreementStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG01_Country (
    CountryKey   NUMBER(3)     NOT NULL,
    CountryCode  CHAR(2)       NOT NULL,
    CountryName  VARCHAR2(60)  NOT NULL
);

COMMENT ON TABLE ORG01_PlatformType IS 'Rodzaj platformy – odpowiedź na pytanie, czym w szerszym kontekście jest źródło ofert.';
COMMENT ON COLUMN ORG01_PlatformType.PlatformTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformType.PlatformTypeName IS 'Nazwa rodzaju platformy';

COMMENT ON TABLE ORG01_SourcePlatform IS 'Platforma, z której pochodzą dane, np. pracuj.pl albo OLX – ta sama tabela co na schemacie z zajęć.';
COMMENT ON COLUMN ORG01_SourcePlatform.SourcePlatformKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_SourcePlatform.SourcePlatformName IS 'Nazwa platformy, np. pracuj.pl';
COMMENT ON COLUMN ORG01_SourcePlatform.MainHomePage IS 'Adres strony głównej';
COMMENT ON COLUMN ORG01_SourcePlatform.PlatformTypeKey IS 'Rodzaj platformy';
COMMENT ON COLUMN ORG01_SourcePlatform.AddedDate IS 'Kiedy dodaliśmy platformę jako źródło';

COMMENT ON TABLE ORG01_PlatformDomain IS 'Adres, pod którym działa platforma. Jedna platforma ma ich kilka.';
COMMENT ON COLUMN ORG01_PlatformDomain.PlatformDomainKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformDomain.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformDomain.DomainName IS 'Domena, np. it.pracuj.pl';
COMMENT ON COLUMN ORG01_PlatformDomain.IsMainDomain IS 'Czy to główny adres platformy';

COMMENT ON TABLE ORG01_PlatformMarket IS 'Kraj, w którym platforma publikuje oferty – tabela łącząca platformy z krajami.';
COMMENT ON COLUMN ORG01_PlatformMarket.PlatformMarketKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformMarket.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformMarket.CountryKey IS 'Kraj';
COMMENT ON COLUMN ORG01_PlatformMarket.LaunchDate IS 'Od kiedy platforma działa w tym kraju';

COMMENT ON TABLE ORG01_PartnerAgreement IS 'Umowa o współpracy z platformą. Każda zmiana warunków to nowy wiersz, więc widać całą historię współpracy.';
COMMENT ON COLUMN ORG01_PartnerAgreement.PartnerAgreementKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PartnerAgreement.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PartnerAgreement.AgreementStatusKey IS 'Etap umowy';
COMMENT ON COLUMN ORG01_PartnerAgreement.SignedDate IS 'Data podpisania';
COMMENT ON COLUMN ORG01_PartnerAgreement.ValidFrom IS 'Od kiedy obowiązuje';
COMMENT ON COLUMN ORG01_PartnerAgreement.ValidTo IS 'Do kiedy obowiązuje (puste = bez końca)';
COMMENT ON COLUMN ORG01_PartnerAgreement.HasDataProcessingAgreement IS 'Czy podpisano umowę powierzenia danych osobowych (RODO)';

COMMENT ON TABLE ORG01_AgreementStatus IS 'Etap umowy z platformą.';
COMMENT ON COLUMN ORG01_AgreementStatus.AgreementStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_AgreementStatus.AgreementStatusName IS 'Nazwa etapu umowy';

COMMENT ON TABLE ORG01_Country IS 'Kraj – słownik używany też w organizmach 6 i 8.';
COMMENT ON COLUMN ORG01_Country.CountryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_Country.CountryCode IS 'Kod kraju ISO, np. PL';
COMMENT ON COLUMN ORG01_Country.CountryName IS 'Nazwa kraju';

ALTER TABLE ORG01_PlatformType ADD CONSTRAINT ORG01_PlatformType_PK PRIMARY KEY (PlatformTypeKey);
ALTER TABLE ORG01_PlatformType ADD CONSTRAINT ORG01_PlatformType_PlatformTypeName_UN UNIQUE (PlatformTypeName);
ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_PK PRIMARY KEY (SourcePlatformKey);
ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_SourcePlatformName_UN UNIQUE (SourcePlatformName);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_PK PRIMARY KEY (PlatformDomainKey);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_DomainName_UN UNIQUE (DomainName);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_IsMainDomain_CK CHECK (IsMainDomain IN ('T', 'N'));
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_PK PRIMARY KEY (PlatformMarketKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_UN UNIQUE (SourcePlatformKey, CountryKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_PK PRIMARY KEY (PartnerAgreementKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_HasDataProcessingAgreement_CK CHECK (HasDataProcessingAgreement IN ('T', 'N'));
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG01_AgreementStatus ADD CONSTRAINT ORG01_AgreementStatus_PK PRIMARY KEY (AgreementStatusKey);
ALTER TABLE ORG01_AgreementStatus ADD CONSTRAINT ORG01_AgreementStatus_AgreementStatusName_UN UNIQUE (AgreementStatusName);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_PK PRIMARY KEY (CountryKey);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_CountryCode_UN UNIQUE (CountryCode);

ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_PlatformType_FK FOREIGN KEY (PlatformTypeKey) REFERENCES ORG01_PlatformType (PlatformTypeKey);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_AgreementStatus_FK FOREIGN KEY (AgreementStatusKey) REFERENCES ORG01_AgreementStatus (AgreementStatusKey);
