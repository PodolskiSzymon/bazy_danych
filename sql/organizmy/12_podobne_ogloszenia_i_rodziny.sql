-- Organizm 12: Podobne ogłoszenia i rodziny
-- Które ogłoszenia są powtórkami i jak długo to samo stanowisko krąży po platformach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE SimilarityType (
    SimilarityTypeKey   NUMBER(2)     NOT NULL,
    SimilarityTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE SimilarityMethod (
    SimilarityMethodKey   NUMBER(3)     NOT NULL,
    SimilarityMethodName  VARCHAR2(60)  NOT NULL,
    MethodVersion         VARCHAR2(20)  NOT NULL,
    ValidFrom             DATE          NOT NULL
);

CREATE TABLE SimilarityPair (
    SimilarityPairKey    NUMBER(12)   NOT NULL,
    FirstJobPostingKey   NUMBER(10)   NOT NULL,
    SecondJobPostingKey  NUMBER(10)   NOT NULL,
    SimilarityTypeKey    NUMBER(2)    NOT NULL,
    SimilarityMethodKey  NUMBER(3)    NOT NULL,
    SimilarityScore      NUMBER(4,3)  NOT NULL,
    DetectedAt           TIMESTAMP    NOT NULL
);

CREATE TABLE FamilyMember (
    FamilyMemberKey   NUMBER(11)  NOT NULL,
    PostingFamilyKey  NUMBER(9)   NOT NULL,
    JobPostingKey     NUMBER(10)  NOT NULL,
    AddedAt           TIMESTAMP   NOT NULL
);

CREATE TABLE PostingFamily (
    PostingFamilyKey  NUMBER(9)      NOT NULL,
    EmployerKey       NUMBER(8)      NOT NULL,
    FamilyLabel       VARCHAR2(200)  NOT NULL,
    FirstSeenDate     DATE           NOT NULL,
    LastSeenDate      DATE           NOT NULL
);

CREATE TABLE FamilyLifecycle (
    FamilyLifecycleKey     NUMBER(10)  NOT NULL,
    PostingFamilyKey       NUMBER(9)   NOT NULL,
    CalculatedOn           DATE        NOT NULL,
    PublicationCount       NUMBER(4)   NOT NULL,
    VisibleDays            NUMBER(5)   NOT NULL,
    GapCount               NUMBER(4)   NOT NULL,
    RefreshCount           NUMBER(5)   NOT NULL,
    PlatformCount          NUMBER(3)   NOT NULL,
    SeniorityVariantCount  NUMBER(2)   NOT NULL
);

COMMENT ON TABLE SimilarityType IS 'Rodzaj powtórki.';
COMMENT ON COLUMN SimilarityType.SimilarityTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SimilarityType.SimilarityTypeName IS 'Nazwa rodzaju powtórki';

COMMENT ON TABLE SimilarityMethod IS 'Metoda liczenia podobieństwa w konkretnej wersji.';
COMMENT ON COLUMN SimilarityMethod.SimilarityMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SimilarityMethod.SimilarityMethodName IS 'Nazwa metody';
COMMENT ON COLUMN SimilarityMethod.MethodVersion IS 'Wersja metody';
COMMENT ON COLUMN SimilarityMethod.ValidFrom IS 'Od kiedy używana';

COMMENT ON TABLE SimilarityPair IS 'Para podobnych ogłoszeń – dwa klucze obce do tej samej tabeli.';
COMMENT ON COLUMN SimilarityPair.SimilarityPairKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SimilarityPair.FirstJobPostingKey IS 'Pierwsze ogłoszenie (wcześniejsze)';
COMMENT ON COLUMN SimilarityPair.SecondJobPostingKey IS 'Drugie ogłoszenie';
COMMENT ON COLUMN SimilarityPair.SimilarityTypeKey IS 'Rodzaj powtórki';
COMMENT ON COLUMN SimilarityPair.SimilarityMethodKey IS 'Metoda';
COMMENT ON COLUMN SimilarityPair.SimilarityScore IS 'Podobieństwo od 0 do 1';
COMMENT ON COLUMN SimilarityPair.DetectedAt IS 'Kiedy wykryto';

COMMENT ON TABLE FamilyMember IS 'Ogłoszenie w rodzinie – tabela łącząca.';
COMMENT ON COLUMN FamilyMember.FamilyMemberKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN FamilyMember.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN FamilyMember.JobPostingKey IS 'Ogłoszenie (najwyżej w jednej rodzinie)';
COMMENT ON COLUMN FamilyMember.AddedAt IS 'Kiedy dołączono do rodziny';

COMMENT ON TABLE PostingFamily IS 'Rodzina ogłoszeń – to samo stanowisko jednej firmy w czasie.';
COMMENT ON COLUMN PostingFamily.PostingFamilyKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingFamily.EmployerKey IS 'Firma';
COMMENT ON COLUMN PostingFamily.FamilyLabel IS 'Opis stanowiska, np. „Księgowa, Kraków”';
COMMENT ON COLUMN PostingFamily.FirstSeenDate IS 'Pierwsza publikacja';
COMMENT ON COLUMN PostingFamily.LastSeenDate IS 'Ostatnia publikacja';

COMMENT ON TABLE FamilyLifecycle IS 'Historia rodziny policzona na dany dzień.';
COMMENT ON COLUMN FamilyLifecycle.FamilyLifecycleKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN FamilyLifecycle.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN FamilyLifecycle.CalculatedOn IS 'Dzień obliczenia';
COMMENT ON COLUMN FamilyLifecycle.PublicationCount IS 'Ile razy publikowano';
COMMENT ON COLUMN FamilyLifecycle.VisibleDays IS 'Ile dni łącznie było widoczne';
COMMENT ON COLUMN FamilyLifecycle.GapCount IS 'Ile razy znikało i wracało';
COMMENT ON COLUMN FamilyLifecycle.RefreshCount IS 'Ile razy odświeżano';
COMMENT ON COLUMN FamilyLifecycle.PlatformCount IS 'Na ilu platformach';
COMMENT ON COLUMN FamilyLifecycle.SeniorityVariantCount IS 'Ile różnych poziomów stanowiska';

ALTER TABLE SimilarityType ADD CONSTRAINT SimilarityType_PK PRIMARY KEY (SimilarityTypeKey);
ALTER TABLE SimilarityType ADD CONSTRAINT SimilarityType_SimilarityTypeName_UN UNIQUE (SimilarityTypeName);
ALTER TABLE SimilarityMethod ADD CONSTRAINT SimilarityMethod_PK PRIMARY KEY (SimilarityMethodKey);
ALTER TABLE SimilarityMethod ADD CONSTRAINT SimilarityMethod_UN UNIQUE (SimilarityMethodName, MethodVersion);
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_PK PRIMARY KEY (SimilarityPairKey);
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_UN UNIQUE (FirstJobPostingKey, SecondJobPostingKey, SimilarityMethodKey);
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_CK1 CHECK (FirstJobPostingKey < SecondJobPostingKey);
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_CK2 CHECK (SimilarityScore BETWEEN 0 AND 1);
ALTER TABLE FamilyMember ADD CONSTRAINT FamilyMember_PK PRIMARY KEY (FamilyMemberKey);
ALTER TABLE FamilyMember ADD CONSTRAINT FamilyMember_JobPostingKey_UN UNIQUE (JobPostingKey);
ALTER TABLE PostingFamily ADD CONSTRAINT PostingFamily_PK PRIMARY KEY (PostingFamilyKey);
ALTER TABLE PostingFamily ADD CONSTRAINT PostingFamily_CK1 CHECK (LastSeenDate >= FirstSeenDate);
ALTER TABLE FamilyLifecycle ADD CONSTRAINT FamilyLifecycle_PK PRIMARY KEY (FamilyLifecycleKey);
ALTER TABLE FamilyLifecycle ADD CONSTRAINT FamilyLifecycle_UN UNIQUE (PostingFamilyKey, CalculatedOn);

ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_SimilarityType_FK FOREIGN KEY (SimilarityTypeKey) REFERENCES SimilarityType (SimilarityTypeKey);
ALTER TABLE SimilarityPair ADD CONSTRAINT SimilarityPair_SimilarityMethod_FK FOREIGN KEY (SimilarityMethodKey) REFERENCES SimilarityMethod (SimilarityMethodKey);
ALTER TABLE FamilyMember ADD CONSTRAINT FamilyMember_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES PostingFamily (PostingFamilyKey);
ALTER TABLE FamilyLifecycle ADD CONSTRAINT FamilyLifecycle_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES PostingFamily (PostingFamilyKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (1, 'Dokładna kopia');
INSERT INTO SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (2, 'Ta sama treść innymi słowami');
INSERT INTO SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (3, 'Ten sam etat z innym poziomem');
INSERT INTO SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (4, 'To samo ogłoszenie na innej platformie');
INSERT INTO SimilarityMethod (SimilarityMethodKey, SimilarityMethodName, MethodVersion, ValidFrom) VALUES (1, 'Porównanie tekstu', '1.0', DATE '2026-11-01');
INSERT INTO SimilarityMethod (SimilarityMethodKey, SimilarityMethodName, MethodVersion, ValidFrom) VALUES (2, 'Wektory znaczenia (model AI)', '1.0', DATE '2026-11-01');
INSERT INTO SimilarityMethod (SimilarityMethodKey, SimilarityMethodName, MethodVersion, ValidFrom) VALUES (3, 'Porównanie cech ogłoszenia', '1.0', DATE '2026-11-01');
COMMIT;
