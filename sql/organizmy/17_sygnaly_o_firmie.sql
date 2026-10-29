-- Organizm 17: Sygnały o firmie
-- Liczby opisujące zachowanie firmy, policzone na dany dzień – wejście do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE SignalGroup (
    SignalGroupKey   NUMBER(2)     NOT NULL,
    SignalGroupName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE SignalSnapshot (
    SignalSnapshotKey  NUMBER(10)  NOT NULL,
    EmployerKey        NUMBER(8)   NOT NULL,
    SnapshotDate       DATE        NOT NULL
);

CREATE TABLE SignalValue (
    SignalValueKey      NUMBER(12)    NOT NULL,
    SignalSnapshotKey   NUMBER(10)    NOT NULL,
    SignalTypeKey       NUMBER(3)     NOT NULL,
    SignalNumericValue  NUMBER(12,4)  NOT NULL,
    BasedOnCount        NUMBER(7)
);

CREATE TABLE SignalType (
    SignalTypeKey      NUMBER(3)      NOT NULL,
    SignalTypeName     VARCHAR2(80)   NOT NULL,
    SignalGroupKey     NUMBER(2)      NOT NULL,
    SignalUnit         VARCHAR2(20)   NOT NULL,
    HigherIsBetter     CHAR(1)        NOT NULL,
    SignalDescription  VARCHAR2(300)
);

COMMENT ON TABLE SignalGroup IS 'Grupa sygnałów.';
COMMENT ON COLUMN SignalGroup.SignalGroupKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SignalGroup.SignalGroupName IS 'Nazwa grupy';

COMMENT ON TABLE SignalSnapshot IS 'Stan sygnałów jednej firmy na dany dzień.';
COMMENT ON COLUMN SignalSnapshot.SignalSnapshotKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SignalSnapshot.EmployerKey IS 'Firma';
COMMENT ON COLUMN SignalSnapshot.SnapshotDate IS 'Na jaki dzień';

COMMENT ON TABLE SignalValue IS 'Wartość jednego sygnału w jednym stanie.';
COMMENT ON COLUMN SignalValue.SignalValueKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SignalValue.SignalSnapshotKey IS 'Stan na dany dzień';
COMMENT ON COLUMN SignalValue.SignalTypeKey IS 'Rodzaj sygnału';
COMMENT ON COLUMN SignalValue.SignalNumericValue IS 'Wartość';
COMMENT ON COLUMN SignalValue.BasedOnCount IS 'Na ilu danych opiera się wartość';

COMMENT ON TABLE SignalType IS 'Rodzaj sygnału z jednostką i kierunkiem.';
COMMENT ON COLUMN SignalType.SignalTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SignalType.SignalTypeName IS 'Nazwa sygnału';
COMMENT ON COLUMN SignalType.SignalGroupKey IS 'Grupa';
COMMENT ON COLUMN SignalType.SignalUnit IS 'Jednostka, np. %, dni, liczba';
COMMENT ON COLUMN SignalType.HigherIsBetter IS 'T = im więcej, tym lepiej dla firmy';
COMMENT ON COLUMN SignalType.SignalDescription IS 'Jak liczymy';

ALTER TABLE SignalGroup ADD CONSTRAINT SignalGroup_PK PRIMARY KEY (SignalGroupKey);
ALTER TABLE SignalGroup ADD CONSTRAINT SignalGroup_SignalGroupName_UN UNIQUE (SignalGroupName);
ALTER TABLE SignalSnapshot ADD CONSTRAINT SignalSnapshot_PK PRIMARY KEY (SignalSnapshotKey);
ALTER TABLE SignalSnapshot ADD CONSTRAINT SignalSnapshot_UN UNIQUE (EmployerKey, SnapshotDate);
ALTER TABLE SignalValue ADD CONSTRAINT SignalValue_PK PRIMARY KEY (SignalValueKey);
ALTER TABLE SignalValue ADD CONSTRAINT SignalValue_UN UNIQUE (SignalSnapshotKey, SignalTypeKey);
ALTER TABLE SignalType ADD CONSTRAINT SignalType_PK PRIMARY KEY (SignalTypeKey);
ALTER TABLE SignalType ADD CONSTRAINT SignalType_SignalTypeName_UN UNIQUE (SignalTypeName);
ALTER TABLE SignalType ADD CONSTRAINT SignalType_HigherIsBetter_CK CHECK (HigherIsBetter IN ('T', 'N'));

ALTER TABLE SignalValue ADD CONSTRAINT SignalValue_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES SignalSnapshot (SignalSnapshotKey);
ALTER TABLE SignalValue ADD CONSTRAINT SignalValue_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES SignalType (SignalTypeKey);
ALTER TABLE SignalType ADD CONSTRAINT SignalType_SignalGroup_FK FOREIGN KEY (SignalGroupKey) REFERENCES SignalGroup (SignalGroupKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO SignalGroup (SignalGroupKey, SignalGroupName) VALUES (1, 'Powtórki ogłoszeń');
INSERT INTO SignalGroup (SignalGroupKey, SignalGroupName) VALUES (2, 'Odpowiedzi firmy na aplikacje');
INSERT INTO SignalGroup (SignalGroupKey, SignalGroupName) VALUES (3, 'Przejrzystość ogłoszeń');
INSERT INTO SignalGroup (SignalGroupKey, SignalGroupName) VALUES (4, 'Dane z rejestrów');
INSERT INTO SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, SignalUnit, HigherIsBetter, SignalDescription) VALUES (1, 'Odsetek ogłoszeń będących powtórkami', 1, '%', 'N', NULL);
INSERT INTO SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, SignalUnit, HigherIsBetter, SignalDescription) VALUES (2, 'Średnia liczba publikacji jednego stanowiska', 1, 'liczba', 'N', NULL);
INSERT INTO SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, SignalUnit, HigherIsBetter, SignalDescription) VALUES (3, 'Zatrudnienia na 100 aplikacji', 2, 'liczba', 'T', NULL);
INSERT INTO SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, SignalUnit, HigherIsBetter, SignalDescription) VALUES (4, 'Zgłoszenia ciszy na 100 aplikacji', 2, 'liczba', 'N', NULL);
INSERT INTO SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, SignalUnit, HigherIsBetter, SignalDescription) VALUES (5, 'Odsetek ogłoszeń z widełkami', 3, '%', 'T', NULL);
INSERT INTO SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, SignalUnit, HigherIsBetter, SignalDescription) VALUES (6, 'Wiek firmy w rejestrze', 4, 'dni', 'T', NULL);
COMMIT;
