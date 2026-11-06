-- Organizm 17: Sygnały o firmie
-- Liczby opisujące zachowanie firmy, policzone na dany dzień – wejście do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG17_SignalGroup (
    SignalGroupKey   NUMBER(2)     NOT NULL,
    SignalGroupName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG17_SignalSnapshot (
    SignalSnapshotKey  NUMBER(10)  NOT NULL,
    EmployerKey        NUMBER(7)   NOT NULL,
    SnapshotDate       DATE        NOT NULL
);

CREATE TABLE ORG17_SignalValue (
    SignalValueKey      NUMBER(11)    NOT NULL,
    SignalSnapshotKey   NUMBER(10)    NOT NULL,
    SignalTypeKey       NUMBER(3)     NOT NULL,
    SignalNumericValue  NUMBER(12,4)  NOT NULL,
    BasedOnCount        NUMBER(7)
);

CREATE TABLE ORG17_SignalType (
    SignalTypeKey      NUMBER(3)      NOT NULL,
    SignalTypeName     VARCHAR2(80)   NOT NULL,
    SignalGroupKey     NUMBER(2)      NOT NULL,
    MeasureUnitKey     NUMBER(2)      NOT NULL,
    HigherIsBetter     NUMBER(1)      NOT NULL,
    SignalDescription  VARCHAR2(300)
);

CREATE TABLE ORG17_MeasureUnit (
    MeasureUnitKey     NUMBER(2)     NOT NULL,
    MeasureUnitName    VARCHAR2(40)  NOT NULL,
    MeasureUnitSymbol  VARCHAR2(10)
);

COMMENT ON TABLE ORG17_SignalGroup IS 'Grupa sygnałów.';
COMMENT ON COLUMN ORG17_SignalGroup.SignalGroupKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalGroup.SignalGroupName IS 'Nazwa grupy';

COMMENT ON TABLE ORG17_SignalSnapshot IS 'Stan sygnałów jednej firmy na dany dzień.';
COMMENT ON COLUMN ORG17_SignalSnapshot.SignalSnapshotKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalSnapshot.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG17_SignalSnapshot.SnapshotDate IS 'Na jaki dzień';

COMMENT ON TABLE ORG17_SignalValue IS 'Wartość jednego sygnału w jednym stanie.';
COMMENT ON COLUMN ORG17_SignalValue.SignalValueKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalValue.SignalSnapshotKey IS 'Stan na dany dzień';
COMMENT ON COLUMN ORG17_SignalValue.SignalTypeKey IS 'Rodzaj sygnału';
COMMENT ON COLUMN ORG17_SignalValue.SignalNumericValue IS 'Wartość';
COMMENT ON COLUMN ORG17_SignalValue.BasedOnCount IS 'Na ilu danych opiera się wartość';

COMMENT ON TABLE ORG17_SignalType IS 'Rodzaj sygnału z jednostką i kierunkiem.';
COMMENT ON COLUMN ORG17_SignalType.SignalTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalType.SignalTypeName IS 'Nazwa sygnału';
COMMENT ON COLUMN ORG17_SignalType.SignalGroupKey IS 'Grupa';
COMMENT ON COLUMN ORG17_SignalType.MeasureUnitKey IS 'Jednostka';
COMMENT ON COLUMN ORG17_SignalType.HigherIsBetter IS '1 = im więcej, tym lepiej dla firmy';
COMMENT ON COLUMN ORG17_SignalType.SignalDescription IS 'Jak liczymy';

COMMENT ON TABLE ORG17_MeasureUnit IS 'Jednostka sygnału – wybierana z listy, a nie wpisywana.';
COMMENT ON COLUMN ORG17_MeasureUnit.MeasureUnitKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_MeasureUnit.MeasureUnitName IS 'Nazwa jednostki';
COMMENT ON COLUMN ORG17_MeasureUnit.MeasureUnitSymbol IS 'Skrót pokazywany przy wartości, np. %';

ALTER TABLE ORG17_SignalGroup ADD CONSTRAINT ORG17_SignalGroup_PK PRIMARY KEY (SignalGroupKey);
ALTER TABLE ORG17_SignalGroup ADD CONSTRAINT ORG17_SignalGroup_SignalGroupName_UN UNIQUE (SignalGroupName);
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_PK PRIMARY KEY (SignalSnapshotKey);
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_UN UNIQUE (EmployerKey, SnapshotDate);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_PK PRIMARY KEY (SignalValueKey);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_UN UNIQUE (SignalSnapshotKey, SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_PK PRIMARY KEY (SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_SignalTypeName_UN UNIQUE (SignalTypeName);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_HigherIsBetter_CK CHECK (HigherIsBetter IN (0, 1));
ALTER TABLE ORG17_MeasureUnit ADD CONSTRAINT ORG17_MeasureUnit_PK PRIMARY KEY (MeasureUnitKey);
ALTER TABLE ORG17_MeasureUnit ADD CONSTRAINT ORG17_MeasureUnit_MeasureUnitName_UN UNIQUE (MeasureUnitName);

ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES ORG17_SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_SignalGroup_FK FOREIGN KEY (SignalGroupKey) REFERENCES ORG17_SignalGroup (SignalGroupKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_MeasureUnit_FK FOREIGN KEY (MeasureUnitKey) REFERENCES ORG17_MeasureUnit (MeasureUnitKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG17_SignalGroup (SignalGroupKey, SignalGroupName) VALUES (1, 'Powtórki ogłoszeń');
INSERT INTO ORG17_SignalGroup (SignalGroupKey, SignalGroupName) VALUES (2, 'Odpowiedzi firmy na aplikacje');
INSERT INTO ORG17_SignalGroup (SignalGroupKey, SignalGroupName) VALUES (3, 'Przejrzystość ogłoszeń');
INSERT INTO ORG17_SignalGroup (SignalGroupKey, SignalGroupName) VALUES (4, 'Dane z rejestrów');
INSERT INTO ORG17_MeasureUnit (MeasureUnitKey, MeasureUnitName, MeasureUnitSymbol) VALUES (1, 'procent', '%');
INSERT INTO ORG17_MeasureUnit (MeasureUnitKey, MeasureUnitName, MeasureUnitSymbol) VALUES (2, 'dzień', 'dni');
INSERT INTO ORG17_MeasureUnit (MeasureUnitKey, MeasureUnitName, MeasureUnitSymbol) VALUES (3, 'liczba', NULL);
INSERT INTO ORG17_MeasureUnit (MeasureUnitKey, MeasureUnitName, MeasureUnitSymbol) VALUES (4, 'liczba na 100 aplikacji', '/100');
INSERT INTO ORG17_SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, MeasureUnitKey, HigherIsBetter, SignalDescription) VALUES (1, 'Odsetek ogłoszeń będących powtórkami', 1, 1, 0, NULL);
INSERT INTO ORG17_SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, MeasureUnitKey, HigherIsBetter, SignalDescription) VALUES (2, 'Średnia liczba publikacji jednego stanowiska', 1, 3, 0, NULL);
INSERT INTO ORG17_SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, MeasureUnitKey, HigherIsBetter, SignalDescription) VALUES (3, 'Zatrudnienia na 100 aplikacji', 2, 4, 1, NULL);
INSERT INTO ORG17_SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, MeasureUnitKey, HigherIsBetter, SignalDescription) VALUES (4, 'Zgłoszenia ciszy na 100 aplikacji', 2, 4, 0, NULL);
INSERT INTO ORG17_SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, MeasureUnitKey, HigherIsBetter, SignalDescription) VALUES (5, 'Odsetek ogłoszeń z widełkami', 3, 1, 1, NULL);
INSERT INTO ORG17_SignalType (SignalTypeKey, SignalTypeName, SignalGroupKey, MeasureUnitKey, HigherIsBetter, SignalDescription) VALUES (6, 'Wiek firmy w rejestrze', 4, 2, 1, NULL);
COMMIT;
