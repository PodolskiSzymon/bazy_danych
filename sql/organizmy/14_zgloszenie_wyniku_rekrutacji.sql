-- Organizm 14: Zgłoszenie wyniku rekrutacji
-- Relacja kandydata o tym, co stało się po aplikacji, i przypomnienia, które go o to pytają.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ReportOutcome (
    ReportOutcomeKey   NUMBER(2)     NOT NULL,
    ReportOutcomeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE RecruitmentReport (
    RecruitmentReportKey   NUMBER(11)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    ReportOutcomeKey       NUMBER(2)   NOT NULL,
    RecruitmentStageKey    NUMBER(2)   NOT NULL,
    ReportChannelKey       NUMBER(2)   NOT NULL,
    ReminderKey            NUMBER(11),
    ReportedAt             TIMESTAMP   NOT NULL
);

CREATE TABLE Reminder (
    ReminderKey        NUMBER(11)  NOT NULL,
    ApplicationKey     NUMBER(12)  NOT NULL,
    ReminderStatusKey  NUMBER(2)   NOT NULL,
    ReminderNumber     NUMBER(1)   NOT NULL,
    SentAt             TIMESTAMP   NOT NULL
);

CREATE TABLE RecruitmentStage (
    RecruitmentStageKey   NUMBER(2)     NOT NULL,
    RecruitmentStageName  VARCHAR2(40)  NOT NULL,
    StageRank             NUMBER(2)     NOT NULL
);

CREATE TABLE ReportChannel (
    ReportChannelKey   NUMBER(2)     NOT NULL,
    ReportChannelName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ReminderStatus (
    ReminderStatusKey   NUMBER(2)     NOT NULL,
    ReminderStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ReportOutcome IS 'Wynik rekrutacji według kandydata.';
COMMENT ON COLUMN ReportOutcome.ReportOutcomeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ReportOutcome.ReportOutcomeName IS 'Nazwa wyniku';

COMMENT ON TABLE RecruitmentReport IS 'Zgłoszenie wyniku rekrutacji – tylko dopisujemy, nie poprawiamy.';
COMMENT ON COLUMN RecruitmentReport.RecruitmentReportKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN RecruitmentReport.CandidatePseudonymKey IS 'Kto zgłasza';
COMMENT ON COLUMN RecruitmentReport.JobPostingKey IS 'Którego ogłoszenia dotyczy';
COMMENT ON COLUMN RecruitmentReport.ReportOutcomeKey IS 'Wynik';
COMMENT ON COLUMN RecruitmentReport.RecruitmentStageKey IS 'Na którym etapie się skończyło';
COMMENT ON COLUMN RecruitmentReport.ReportChannelKey IS 'Jak zgłoszono';
COMMENT ON COLUMN RecruitmentReport.ReminderKey IS 'Przypomnienie, po którym przyszło zgłoszenie';
COMMENT ON COLUMN RecruitmentReport.ReportedAt IS 'Kiedy zgłoszono';

COMMENT ON TABLE Reminder IS 'Przypomnienie wysłane kandydatowi przez platformę na naszą prośbę.';
COMMENT ON COLUMN Reminder.ReminderKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Reminder.ApplicationKey IS 'Aplikacja, o którą pytamy';
COMMENT ON COLUMN Reminder.ReminderStatusKey IS 'Co się stało z przypomnieniem';
COMMENT ON COLUMN Reminder.ReminderNumber IS 'Które to przypomnienie (1, 2…)';
COMMENT ON COLUMN Reminder.SentAt IS 'Kiedy zlecono';

COMMENT ON TABLE RecruitmentStage IS 'Etap rekrutacji.';
COMMENT ON COLUMN RecruitmentStage.RecruitmentStageKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN RecruitmentStage.RecruitmentStageName IS 'Nazwa etapu';
COMMENT ON COLUMN RecruitmentStage.StageRank IS 'Kolejność etapów';

COMMENT ON TABLE ReportChannel IS 'Jak przyszło zgłoszenie.';
COMMENT ON COLUMN ReportChannel.ReportChannelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ReportChannel.ReportChannelName IS 'Nazwa kanału';

COMMENT ON TABLE ReminderStatus IS 'Los przypomnienia.';
COMMENT ON COLUMN ReminderStatus.ReminderStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ReminderStatus.ReminderStatusName IS 'Nazwa stanu przypomnienia';

ALTER TABLE ReportOutcome ADD CONSTRAINT ReportOutcome_PK PRIMARY KEY (ReportOutcomeKey);
ALTER TABLE ReportOutcome ADD CONSTRAINT ReportOutcome_ReportOutcomeName_UN UNIQUE (ReportOutcomeName);
ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_PK PRIMARY KEY (RecruitmentReportKey);
ALTER TABLE Reminder ADD CONSTRAINT Reminder_PK PRIMARY KEY (ReminderKey);
ALTER TABLE Reminder ADD CONSTRAINT Reminder_UN UNIQUE (ApplicationKey, ReminderNumber);
ALTER TABLE RecruitmentStage ADD CONSTRAINT RecruitmentStage_PK PRIMARY KEY (RecruitmentStageKey);
ALTER TABLE RecruitmentStage ADD CONSTRAINT RecruitmentStage_RecruitmentStageName_UN UNIQUE (RecruitmentStageName);
ALTER TABLE ReportChannel ADD CONSTRAINT ReportChannel_PK PRIMARY KEY (ReportChannelKey);
ALTER TABLE ReportChannel ADD CONSTRAINT ReportChannel_ReportChannelName_UN UNIQUE (ReportChannelName);
ALTER TABLE ReminderStatus ADD CONSTRAINT ReminderStatus_PK PRIMARY KEY (ReminderStatusKey);
ALTER TABLE ReminderStatus ADD CONSTRAINT ReminderStatus_ReminderStatusName_UN UNIQUE (ReminderStatusName);

ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_ReportOutcome_FK FOREIGN KEY (ReportOutcomeKey) REFERENCES ReportOutcome (ReportOutcomeKey);
ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_RecruitmentStage_FK FOREIGN KEY (RecruitmentStageKey) REFERENCES RecruitmentStage (RecruitmentStageKey);
ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_ReportChannel_FK FOREIGN KEY (ReportChannelKey) REFERENCES ReportChannel (ReportChannelKey);
ALTER TABLE RecruitmentReport ADD CONSTRAINT RecruitmentReport_Reminder_FK FOREIGN KEY (ReminderKey) REFERENCES Reminder (ReminderKey);
ALTER TABLE Reminder ADD CONSTRAINT Reminder_ReminderStatus_FK FOREIGN KEY (ReminderStatusKey) REFERENCES ReminderStatus (ReminderStatusKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (1, 'Brak odpowiedzi (cisza)');
INSERT INTO ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (2, 'Automatyczna odmowa');
INSERT INTO ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (3, 'Odmowa po rozmowie');
INSERT INTO ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (4, 'Oferta wycofana');
INSERT INTO ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (5, 'Zatrudnienie');
INSERT INTO ReportOutcome (ReportOutcomeKey, ReportOutcomeName) VALUES (6, 'Ogłoszenie było nieaktualne');
INSERT INTO RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (1, 'Po wysłaniu CV', 1);
INSERT INTO RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (2, 'Po zadaniu lub teście', 2);
INSERT INTO RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (3, 'Po pierwszej rozmowie', 3);
INSERT INTO RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (4, 'Po kolejnej rozmowie', 4);
INSERT INTO RecruitmentStage (RecruitmentStageKey, RecruitmentStageName, StageRank) VALUES (5, 'Po otrzymaniu oferty', 5);
INSERT INTO ReportChannel (ReportChannelKey, ReportChannelName) VALUES (1, 'Formularz w widżecie');
INSERT INTO ReportChannel (ReportChannelKey, ReportChannelName) VALUES (2, 'Odpowiedź na przypomnienie');
INSERT INTO ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (1, 'Zlecone platformie');
INSERT INTO ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (2, 'Dostarczone');
INSERT INTO ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (3, 'Bez odpowiedzi');
INSERT INTO ReminderStatus (ReminderStatusKey, ReminderStatusName) VALUES (4, 'Kandydat odpowiedział');
COMMIT;
