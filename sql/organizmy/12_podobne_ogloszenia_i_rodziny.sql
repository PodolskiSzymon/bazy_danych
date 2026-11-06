-- Organizm 12: Podobne ogłoszenia i rodziny
-- Które ogłoszenia są powtórkami i jak długo to samo stanowisko krąży po platformach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG12_SimilarityType (
    SimilarityTypeKey   NUMBER(2)     NOT NULL,
    SimilarityTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG12_SimilarityMethod (
    SimilarityMethodKey   NUMBER(2)     NOT NULL,
    SimilarityMethodName  VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG12_SimilarityMethodVersion (
    SimilarityMethodVersionKey  NUMBER(3)     NOT NULL,
    SimilarityMethodKey         NUMBER(2)     NOT NULL,
    VersionLabel                VARCHAR2(20)  NOT NULL,
    ValidFrom                   DATE          NOT NULL,
    ValidTo                     DATE,
    IsCurrent                   NUMBER(1)     NOT NULL
);

CREATE TABLE ORG12_SimilarityPair (
    SimilarityPairKey           NUMBER(10)   NOT NULL,
    FirstJobPostingKey          NUMBER(9)    NOT NULL,
    SecondJobPostingKey         NUMBER(9)    NOT NULL,
    SimilarityTypeKey           NUMBER(2)    NOT NULL,
    SimilarityMethodVersionKey  NUMBER(3)    NOT NULL,
    SimilarityScore             NUMBER(4,3)  NOT NULL,
    DetectedAt                  TIMESTAMP    NOT NULL
);

CREATE TABLE ORG12_FamilyMember (
    FamilyMemberKey   NUMBER(9)  NOT NULL,
    PostingFamilyKey  NUMBER(8)  NOT NULL,
    JobPostingKey     NUMBER(9)  NOT NULL,
    AddedAt           TIMESTAMP  NOT NULL,
    RemovedAt         TIMESTAMP,
    IsCurrent         NUMBER(1)  NOT NULL
);

CREATE TABLE ORG12_PostingFamily (
    PostingFamilyKey  NUMBER(8)      NOT NULL,
    EmployerKey       NUMBER(7)      NOT NULL,
    FamilyLabel       VARCHAR2(200)  NOT NULL,
    FirstSeenDate     DATE           NOT NULL,
    LastSeenDate      DATE           NOT NULL
);

CREATE TABLE ORG12_FamilyLifecycle (
    FamilyLifecycleKey     NUMBER(10)  NOT NULL,
    PostingFamilyKey       NUMBER(8)   NOT NULL,
    CalculatedOn           DATE        NOT NULL,
    PublicationCount       NUMBER(4)   NOT NULL,
    VisibleDays            NUMBER(5)   NOT NULL,
    GapCount               NUMBER(4)   NOT NULL,
    RefreshCount           NUMBER(5)   NOT NULL,
    PlatformCount          NUMBER(3)   NOT NULL,
    SeniorityVariantCount  NUMBER(2)   NOT NULL
);

COMMENT ON TABLE ORG12_SimilarityType IS 'Rodzaj powtórki.';
COMMENT ON COLUMN ORG12_SimilarityType.SimilarityTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityType.SimilarityTypeName IS 'Nazwa rodzaju powtórki';

COMMENT ON TABLE ORG12_SimilarityMethod IS 'Metoda liczenia podobieństwa – nazwa wybierana z listy.';
COMMENT ON COLUMN ORG12_SimilarityMethod.SimilarityMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityMethod.SimilarityMethodName IS 'Nazwa metody';

COMMENT ON TABLE ORG12_SimilarityMethodVersion IS 'Wersja metody liczenia podobieństwa – z jednej wersji każdej metody korzystamy teraz.';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.SimilarityMethodVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.SimilarityMethodKey IS 'Metoda';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.VersionLabel IS 'Wersja, np. 1.0';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.ValidFrom IS 'Od kiedy używana';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.IsCurrent IS '1 = wersja używana teraz';

COMMENT ON TABLE ORG12_SimilarityPair IS 'Para podobnych ogłoszeń – dwa klucze obce do tej samej tabeli.';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityPairKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityPair.FirstJobPostingKey IS 'Pierwsze ogłoszenie (wcześniejsze)';
COMMENT ON COLUMN ORG12_SimilarityPair.SecondJobPostingKey IS 'Drugie ogłoszenie';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityTypeKey IS 'Rodzaj powtórki';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityMethodVersionKey IS 'Metoda w konkretnej wersji';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityScore IS 'Podobieństwo od 0 do 1';
COMMENT ON COLUMN ORG12_SimilarityPair.DetectedAt IS 'Kiedy wykryto';

COMMENT ON TABLE ORG12_FamilyMember IS 'Ogłoszenie w rodzinie – przypisanie w czasie; w danej chwili ogłoszenie jest najwyżej w jednej rodzinie.';
COMMENT ON COLUMN ORG12_FamilyMember.FamilyMemberKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_FamilyMember.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN ORG12_FamilyMember.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG12_FamilyMember.AddedAt IS 'Kiedy dołączono do rodziny';
COMMENT ON COLUMN ORG12_FamilyMember.RemovedAt IS 'Kiedy przeniesiono do innej rodziny (puste = nadal)';
COMMENT ON COLUMN ORG12_FamilyMember.IsCurrent IS '1 = członkostwo aktualne';

COMMENT ON TABLE ORG12_PostingFamily IS 'Rodzina ogłoszeń – to samo stanowisko jednej firmy w czasie.';
COMMENT ON COLUMN ORG12_PostingFamily.PostingFamilyKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_PostingFamily.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG12_PostingFamily.FamilyLabel IS 'Opis stanowiska, np. „Księgowa, Kraków”';
COMMENT ON COLUMN ORG12_PostingFamily.FirstSeenDate IS 'Pierwsza publikacja';
COMMENT ON COLUMN ORG12_PostingFamily.LastSeenDate IS 'Ostatnia publikacja';

COMMENT ON TABLE ORG12_FamilyLifecycle IS 'Historia rodziny policzona na dany dzień.';
COMMENT ON COLUMN ORG12_FamilyLifecycle.FamilyLifecycleKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_FamilyLifecycle.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN ORG12_FamilyLifecycle.CalculatedOn IS 'Dzień obliczenia';
COMMENT ON COLUMN ORG12_FamilyLifecycle.PublicationCount IS 'Ile razy publikowano';
COMMENT ON COLUMN ORG12_FamilyLifecycle.VisibleDays IS 'Ile dni łącznie było widoczne';
COMMENT ON COLUMN ORG12_FamilyLifecycle.GapCount IS 'Ile razy znikało i wracało';
COMMENT ON COLUMN ORG12_FamilyLifecycle.RefreshCount IS 'Ile razy odświeżano';
COMMENT ON COLUMN ORG12_FamilyLifecycle.PlatformCount IS 'Na ilu platformach';
COMMENT ON COLUMN ORG12_FamilyLifecycle.SeniorityVariantCount IS 'Ile różnych poziomów stanowiska';

ALTER TABLE ORG12_SimilarityType ADD CONSTRAINT ORG12_SimilarityType_PK PRIMARY KEY (SimilarityTypeKey);
ALTER TABLE ORG12_SimilarityType ADD CONSTRAINT ORG12_SimilarityType_SimilarityTypeName_UN UNIQUE (SimilarityTypeName);
ALTER TABLE ORG12_SimilarityMethod ADD CONSTRAINT ORG12_SimilarityMethod_PK PRIMARY KEY (SimilarityMethodKey);
ALTER TABLE ORG12_SimilarityMethod ADD CONSTRAINT ORG12_SimilarityMethod_SimilarityMethodName_UN UNIQUE (SimilarityMethodName);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_PK PRIMARY KEY (SimilarityMethodVersionKey);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_UN UNIQUE (SimilarityMethodKey, VersionLabel);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_PK PRIMARY KEY (SimilarityPairKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_UN UNIQUE (FirstJobPostingKey, SecondJobPostingKey, SimilarityMethodVersionKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_CK1 CHECK (FirstJobPostingKey < SecondJobPostingKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_CK2 CHECK (SimilarityScore BETWEEN 0 AND 1);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_PK PRIMARY KEY (FamilyMemberKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_CK1 CHECK (RemovedAt IS NULL OR RemovedAt >= AddedAt);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_CK2 CHECK (IsCurrent = 1 OR RemovedAt IS NOT NULL);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_PK PRIMARY KEY (PostingFamilyKey);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_CK1 CHECK (LastSeenDate >= FirstSeenDate);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_PK PRIMARY KEY (FamilyLifecycleKey);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_UN UNIQUE (PostingFamilyKey, CalculatedOn);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_CK1 CHECK (PublicationCount >= 0 AND VisibleDays >= 0 AND GapCount >= 0 AND RefreshCount >= 0 AND PlatformCount >= 0 AND SeniorityVariantCount >= 0);

ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_SimilarityMethod_FK FOREIGN KEY (SimilarityMethodKey) REFERENCES ORG12_SimilarityMethod (SimilarityMethodKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SimilarityType_FK FOREIGN KEY (SimilarityTypeKey) REFERENCES ORG12_SimilarityType (SimilarityTypeKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SimilarityMethodVersion_FK FOREIGN KEY (SimilarityMethodVersionKey) REFERENCES ORG12_SimilarityMethodVersion (SimilarityMethodVersionKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES ORG12_PostingFamily (PostingFamilyKey);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES ORG12_PostingFamily (PostingFamilyKey);

-- Unikalne tylko w części wierszy, np. jeden aktualny wiersz (unikalny indeks funkcyjny).
CREATE UNIQUE INDEX ORG12_SimilarityMethodVersion_UX ON ORG12_SimilarityMethodVersion (CASE WHEN IsCurrent = 1 THEN SimilarityMethodKey END);
CREATE UNIQUE INDEX ORG12_FamilyMember_UX ON ORG12_FamilyMember (CASE WHEN IsCurrent = 1 THEN JobPostingKey END);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG12_SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (1, 'Dokładna kopia');
INSERT INTO ORG12_SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (2, 'Ta sama treść innymi słowami');
INSERT INTO ORG12_SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (3, 'Ten sam etat z innym poziomem');
INSERT INTO ORG12_SimilarityType (SimilarityTypeKey, SimilarityTypeName) VALUES (4, 'To samo ogłoszenie na innej platformie');
INSERT INTO ORG12_SimilarityMethod (SimilarityMethodKey, SimilarityMethodName) VALUES (1, 'Porównanie tekstu');
INSERT INTO ORG12_SimilarityMethod (SimilarityMethodKey, SimilarityMethodName) VALUES (2, 'Wektory znaczenia (model AI)');
INSERT INTO ORG12_SimilarityMethod (SimilarityMethodKey, SimilarityMethodName) VALUES (3, 'Porównanie cech ogłoszenia');
INSERT INTO ORG12_SimilarityMethodVersion (SimilarityMethodVersionKey, SimilarityMethodKey, VersionLabel, ValidFrom, ValidTo, IsCurrent) VALUES (1, 1, '1.0', DATE '2026-11-01', NULL, 1);
INSERT INTO ORG12_SimilarityMethodVersion (SimilarityMethodVersionKey, SimilarityMethodKey, VersionLabel, ValidFrom, ValidTo, IsCurrent) VALUES (2, 2, '1.0', DATE '2026-11-01', NULL, 1);
INSERT INTO ORG12_SimilarityMethodVersion (SimilarityMethodVersionKey, SimilarityMethodKey, VersionLabel, ValidFrom, ValidTo, IsCurrent) VALUES (3, 3, '1.0', DATE '2026-11-01', NULL, 1);
COMMIT;
