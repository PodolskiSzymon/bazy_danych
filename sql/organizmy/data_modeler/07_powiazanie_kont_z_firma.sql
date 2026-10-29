-- Organizm 7: Powiązanie kont z firmą
-- Które konta z różnych platform należą do tej samej firmy – z dowodami i historią zmian.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG07_MatchMethod (
    MatchMethodKey   NUMBER(2)     NOT NULL,
    MatchMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG07_LinkEvidence (
    LinkEvidenceKey         NUMBER(10)     NOT NULL,
    AccountEmployerLinkKey  NUMBER(9)      NOT NULL,
    EvidenceTypeKey         NUMBER(2)      NOT NULL,
    EvidenceValue           VARCHAR2(250)  NOT NULL
);

CREATE TABLE ORG07_AccountEmployerLink (
    AccountEmployerLinkKey  NUMBER(9)    NOT NULL,
    EmployerAccountKey      NUMBER(8)    NOT NULL,
    EmployerKey             NUMBER(8)    NOT NULL,
    MatchMethodKey          NUMBER(2)    NOT NULL,
    MatchConfidence         NUMBER(3,2)  NOT NULL,
    LinkedAt                TIMESTAMP    NOT NULL,
    UnlinkedAt              TIMESTAMP
);

CREATE TABLE ORG07_AgencyClient (
    AgencyClientKey    NUMBER(8)  NOT NULL,
    AgencyEmployerKey  NUMBER(8)  NOT NULL,
    ClientEmployerKey  NUMBER(8)  NOT NULL,
    ValidFrom          DATE       NOT NULL,
    ValidTo            DATE
);

CREATE TABLE ORG07_EvidenceType (
    EvidenceTypeKey   NUMBER(2)     NOT NULL,
    EvidenceTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG07_LinkChange (
    LinkChangeKey           NUMBER(10)     NOT NULL,
    AccountEmployerLinkKey  NUMBER(9)      NOT NULL,
    LinkChangeTypeKey       NUMBER(2)      NOT NULL,
    ChangedAt               TIMESTAMP      NOT NULL,
    ChangeReason            VARCHAR2(300)
);

CREATE TABLE ORG07_LinkChangeType (
    LinkChangeTypeKey   NUMBER(2)     NOT NULL,
    LinkChangeTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG07_MatchMethod IS 'Sposób, w jaki dopasowaliśmy konto do firmy.';
COMMENT ON COLUMN ORG07_MatchMethod.MatchMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_MatchMethod.MatchMethodName IS 'Nazwa sposobu dopasowania';

COMMENT ON TABLE ORG07_LinkEvidence IS 'Dowód, na którym opiera się powiązanie.';
COMMENT ON COLUMN ORG07_LinkEvidence.LinkEvidenceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkEvidence.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN ORG07_LinkEvidence.EvidenceTypeKey IS 'Rodzaj dowodu';
COMMENT ON COLUMN ORG07_LinkEvidence.EvidenceValue IS 'Treść dowodu, np. „ten sam NIP w koncie i w KRS”';

COMMENT ON TABLE ORG07_AccountEmployerLink IS 'Powiązanie konta na platformie z firmą z rejestru.';
COMMENT ON COLUMN ORG07_AccountEmployerLink.AccountEmployerLinkKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_AccountEmployerLink.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN ORG07_AccountEmployerLink.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG07_AccountEmployerLink.MatchMethodKey IS 'Sposób dopasowania';
COMMENT ON COLUMN ORG07_AccountEmployerLink.MatchConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN ORG07_AccountEmployerLink.LinkedAt IS 'Kiedy połączono';
COMMENT ON COLUMN ORG07_AccountEmployerLink.UnlinkedAt IS 'Kiedy cofnięto (puste = obowiązuje)';

COMMENT ON TABLE ORG07_AgencyClient IS 'Agencja rekrutacyjna i firma, dla której rekrutuje – dwa klucze do tej samej tabeli.';
COMMENT ON COLUMN ORG07_AgencyClient.AgencyClientKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_AgencyClient.AgencyEmployerKey IS 'Agencja rekrutacyjna';
COMMENT ON COLUMN ORG07_AgencyClient.ClientEmployerKey IS 'Firma, dla której agencja rekrutuje';
COMMENT ON COLUMN ORG07_AgencyClient.ValidFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG07_AgencyClient.ValidTo IS 'Do kiedy (puste = nadal)';

COMMENT ON TABLE ORG07_EvidenceType IS 'Rodzaj dowodu powiązania.';
COMMENT ON COLUMN ORG07_EvidenceType.EvidenceTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_EvidenceType.EvidenceTypeName IS 'Nazwa rodzaju dowodu';

COMMENT ON TABLE ORG07_LinkChange IS 'Zmiana powiązania – historia połączeń i rozłączeń.';
COMMENT ON COLUMN ORG07_LinkChange.LinkChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkChange.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN ORG07_LinkChange.LinkChangeTypeKey IS 'Co zmieniono';
COMMENT ON COLUMN ORG07_LinkChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN ORG07_LinkChange.ChangeReason IS 'Dlaczego';

COMMENT ON TABLE ORG07_LinkChangeType IS 'Rodzaj zmiany powiązania.';
COMMENT ON COLUMN ORG07_LinkChangeType.LinkChangeTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkChangeType.LinkChangeTypeName IS 'Nazwa rodzaju zmiany';

ALTER TABLE ORG07_MatchMethod ADD CONSTRAINT ORG07_MatchMethod_PK PRIMARY KEY (MatchMethodKey);
ALTER TABLE ORG07_MatchMethod ADD CONSTRAINT ORG07_MatchMethod_MatchMethodName_UN UNIQUE (MatchMethodName);
ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_PK PRIMARY KEY (LinkEvidenceKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_PK PRIMARY KEY (AccountEmployerLinkKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK1 CHECK (MatchConfidence BETWEEN 0 AND 1);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK2 CHECK (UnlinkedAt IS NULL OR UnlinkedAt >= LinkedAt);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_PK PRIMARY KEY (AgencyClientKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_UN UNIQUE (AgencyEmployerKey, ClientEmployerKey, ValidFrom);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK1 CHECK (AgencyEmployerKey <> ClientEmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK2 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG07_EvidenceType ADD CONSTRAINT ORG07_EvidenceType_PK PRIMARY KEY (EvidenceTypeKey);
ALTER TABLE ORG07_EvidenceType ADD CONSTRAINT ORG07_EvidenceType_EvidenceTypeName_UN UNIQUE (EvidenceTypeName);
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_PK PRIMARY KEY (LinkChangeKey);
ALTER TABLE ORG07_LinkChangeType ADD CONSTRAINT ORG07_LinkChangeType_PK PRIMARY KEY (LinkChangeTypeKey);
ALTER TABLE ORG07_LinkChangeType ADD CONSTRAINT ORG07_LinkChangeType_LinkChangeTypeName_UN UNIQUE (LinkChangeTypeName);

ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_AccountEmployerLink_FK FOREIGN KEY (AccountEmployerLinkKey) REFERENCES ORG07_AccountEmployerLink (AccountEmployerLinkKey);
ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_EvidenceType_FK FOREIGN KEY (EvidenceTypeKey) REFERENCES ORG07_EvidenceType (EvidenceTypeKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_MatchMethod_FK FOREIGN KEY (MatchMethodKey) REFERENCES ORG07_MatchMethod (MatchMethodKey);
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_AccountEmployerLink_FK FOREIGN KEY (AccountEmployerLinkKey) REFERENCES ORG07_AccountEmployerLink (AccountEmployerLinkKey);
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_LinkChangeType_FK FOREIGN KEY (LinkChangeTypeKey) REFERENCES ORG07_LinkChangeType (LinkChangeTypeKey);
