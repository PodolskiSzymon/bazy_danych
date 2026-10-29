-- Organizm 7: Powiązanie kont z firmą
-- Które konta z różnych platform należą do tej samej firmy – z dowodami i historią zmian.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE MatchMethod (
    MatchMethodKey   NUMBER(2)     NOT NULL,
    MatchMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE LinkEvidence (
    LinkEvidenceKey         NUMBER(10)     NOT NULL,
    AccountEmployerLinkKey  NUMBER(9)      NOT NULL,
    EvidenceTypeKey         NUMBER(2)      NOT NULL,
    EvidenceValue           VARCHAR2(250)  NOT NULL
);

CREATE TABLE AccountEmployerLink (
    AccountEmployerLinkKey  NUMBER(9)    NOT NULL,
    EmployerAccountKey      NUMBER(8)    NOT NULL,
    EmployerKey             NUMBER(8)    NOT NULL,
    MatchMethodKey          NUMBER(2)    NOT NULL,
    MatchConfidence         NUMBER(3,2)  NOT NULL,
    LinkedAt                TIMESTAMP    NOT NULL,
    UnlinkedAt              TIMESTAMP
);

CREATE TABLE AgencyClient (
    AgencyClientKey    NUMBER(8)  NOT NULL,
    AgencyEmployerKey  NUMBER(8)  NOT NULL,
    ClientEmployerKey  NUMBER(8)  NOT NULL,
    ValidFrom          DATE       NOT NULL,
    ValidTo            DATE
);

CREATE TABLE EvidenceType (
    EvidenceTypeKey   NUMBER(2)     NOT NULL,
    EvidenceTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE LinkChange (
    LinkChangeKey           NUMBER(10)     NOT NULL,
    AccountEmployerLinkKey  NUMBER(9)      NOT NULL,
    LinkChangeTypeKey       NUMBER(2)      NOT NULL,
    ChangedAt               TIMESTAMP      NOT NULL,
    ChangeReason            VARCHAR2(300)
);

CREATE TABLE LinkChangeType (
    LinkChangeTypeKey   NUMBER(2)     NOT NULL,
    LinkChangeTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE MatchMethod IS 'Sposób, w jaki dopasowaliśmy konto do firmy.';
COMMENT ON COLUMN MatchMethod.MatchMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN MatchMethod.MatchMethodName IS 'Nazwa sposobu dopasowania';

COMMENT ON TABLE LinkEvidence IS 'Dowód, na którym opiera się powiązanie.';
COMMENT ON COLUMN LinkEvidence.LinkEvidenceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN LinkEvidence.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN LinkEvidence.EvidenceTypeKey IS 'Rodzaj dowodu';
COMMENT ON COLUMN LinkEvidence.EvidenceValue IS 'Treść dowodu, np. „ten sam NIP w koncie i w KRS”';

COMMENT ON TABLE AccountEmployerLink IS 'Powiązanie konta na platformie z firmą z rejestru.';
COMMENT ON COLUMN AccountEmployerLink.AccountEmployerLinkKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AccountEmployerLink.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN AccountEmployerLink.EmployerKey IS 'Firma';
COMMENT ON COLUMN AccountEmployerLink.MatchMethodKey IS 'Sposób dopasowania';
COMMENT ON COLUMN AccountEmployerLink.MatchConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN AccountEmployerLink.LinkedAt IS 'Kiedy połączono';
COMMENT ON COLUMN AccountEmployerLink.UnlinkedAt IS 'Kiedy cofnięto (puste = obowiązuje)';

COMMENT ON TABLE AgencyClient IS 'Agencja rekrutacyjna i firma, dla której rekrutuje – dwa klucze do tej samej tabeli.';
COMMENT ON COLUMN AgencyClient.AgencyClientKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AgencyClient.AgencyEmployerKey IS 'Agencja rekrutacyjna';
COMMENT ON COLUMN AgencyClient.ClientEmployerKey IS 'Firma, dla której agencja rekrutuje';
COMMENT ON COLUMN AgencyClient.ValidFrom IS 'Od kiedy';
COMMENT ON COLUMN AgencyClient.ValidTo IS 'Do kiedy (puste = nadal)';

COMMENT ON TABLE EvidenceType IS 'Rodzaj dowodu powiązania.';
COMMENT ON COLUMN EvidenceType.EvidenceTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EvidenceType.EvidenceTypeName IS 'Nazwa rodzaju dowodu';

COMMENT ON TABLE LinkChange IS 'Zmiana powiązania – historia połączeń i rozłączeń.';
COMMENT ON COLUMN LinkChange.LinkChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN LinkChange.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN LinkChange.LinkChangeTypeKey IS 'Co zmieniono';
COMMENT ON COLUMN LinkChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN LinkChange.ChangeReason IS 'Dlaczego';

COMMENT ON TABLE LinkChangeType IS 'Rodzaj zmiany powiązania.';
COMMENT ON COLUMN LinkChangeType.LinkChangeTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN LinkChangeType.LinkChangeTypeName IS 'Nazwa rodzaju zmiany';

ALTER TABLE MatchMethod ADD CONSTRAINT MatchMethod_PK PRIMARY KEY (MatchMethodKey);
ALTER TABLE MatchMethod ADD CONSTRAINT MatchMethod_MatchMethodName_UN UNIQUE (MatchMethodName);
ALTER TABLE LinkEvidence ADD CONSTRAINT LinkEvidence_PK PRIMARY KEY (LinkEvidenceKey);
ALTER TABLE AccountEmployerLink ADD CONSTRAINT AccountEmployerLink_PK PRIMARY KEY (AccountEmployerLinkKey);
ALTER TABLE AccountEmployerLink ADD CONSTRAINT AccountEmployerLink_CK1 CHECK (MatchConfidence BETWEEN 0 AND 1);
ALTER TABLE AccountEmployerLink ADD CONSTRAINT AccountEmployerLink_CK2 CHECK (UnlinkedAt IS NULL OR UnlinkedAt >= LinkedAt);
ALTER TABLE AgencyClient ADD CONSTRAINT AgencyClient_PK PRIMARY KEY (AgencyClientKey);
ALTER TABLE AgencyClient ADD CONSTRAINT AgencyClient_UN UNIQUE (AgencyEmployerKey, ClientEmployerKey, ValidFrom);
ALTER TABLE AgencyClient ADD CONSTRAINT AgencyClient_CK1 CHECK (AgencyEmployerKey <> ClientEmployerKey);
ALTER TABLE EvidenceType ADD CONSTRAINT EvidenceType_PK PRIMARY KEY (EvidenceTypeKey);
ALTER TABLE EvidenceType ADD CONSTRAINT EvidenceType_EvidenceTypeName_UN UNIQUE (EvidenceTypeName);
ALTER TABLE LinkChange ADD CONSTRAINT LinkChange_PK PRIMARY KEY (LinkChangeKey);
ALTER TABLE LinkChangeType ADD CONSTRAINT LinkChangeType_PK PRIMARY KEY (LinkChangeTypeKey);
ALTER TABLE LinkChangeType ADD CONSTRAINT LinkChangeType_LinkChangeTypeName_UN UNIQUE (LinkChangeTypeName);

ALTER TABLE LinkEvidence ADD CONSTRAINT LinkEvidence_AccountEmployerLink_FK FOREIGN KEY (AccountEmployerLinkKey) REFERENCES AccountEmployerLink (AccountEmployerLinkKey);
ALTER TABLE LinkEvidence ADD CONSTRAINT LinkEvidence_EvidenceType_FK FOREIGN KEY (EvidenceTypeKey) REFERENCES EvidenceType (EvidenceTypeKey);
ALTER TABLE AccountEmployerLink ADD CONSTRAINT AccountEmployerLink_MatchMethod_FK FOREIGN KEY (MatchMethodKey) REFERENCES MatchMethod (MatchMethodKey);
ALTER TABLE LinkChange ADD CONSTRAINT LinkChange_AccountEmployerLink_FK FOREIGN KEY (AccountEmployerLinkKey) REFERENCES AccountEmployerLink (AccountEmployerLinkKey);
ALTER TABLE LinkChange ADD CONSTRAINT LinkChange_LinkChangeType_FK FOREIGN KEY (LinkChangeTypeKey) REFERENCES LinkChangeType (LinkChangeTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO MatchMethod (MatchMethodKey, MatchMethodName) VALUES (1, 'Ten sam NIP');
INSERT INTO MatchMethod (MatchMethodKey, MatchMethodName) VALUES (2, 'Podobna nazwa i ta sama strona www');
INSERT INTO MatchMethod (MatchMethodKey, MatchMethodName) VALUES (3, 'Decyzja moderatora');
INSERT INTO MatchMethod (MatchMethodKey, MatchMethodName) VALUES (4, 'Potwierdzenie przez firmę');
INSERT INTO EvidenceType (EvidenceTypeKey, EvidenceTypeName) VALUES (1, 'Zgodny NIP');
INSERT INTO EvidenceType (EvidenceTypeKey, EvidenceTypeName) VALUES (2, 'Podobna nazwa');
INSERT INTO EvidenceType (EvidenceTypeKey, EvidenceTypeName) VALUES (3, 'Ta sama domena strony www');
INSERT INTO EvidenceType (EvidenceTypeKey, EvidenceTypeName) VALUES (4, 'Ten sam adres');
INSERT INTO EvidenceType (EvidenceTypeKey, EvidenceTypeName) VALUES (5, 'Dokument przesłany przez firmę');
INSERT INTO LinkChangeType (LinkChangeTypeKey, LinkChangeTypeName) VALUES (1, 'Połączono');
INSERT INTO LinkChangeType (LinkChangeTypeKey, LinkChangeTypeName) VALUES (2, 'Rozłączono');
INSERT INTO LinkChangeType (LinkChangeTypeKey, LinkChangeTypeName) VALUES (3, 'Przeniesiono do innej firmy');
INSERT INTO LinkChangeType (LinkChangeTypeKey, LinkChangeTypeName) VALUES (4, 'Zmieniono pewność');
COMMIT;
