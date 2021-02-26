USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 16:14:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE [dbo].[ExperimentTypes]
Go
*/

CREATE TABLE [dbo].[ExperimentTypes](
	[ID] [int] NOT NULL PRIMARY KEY,
	[ExperimentID] [int] NOT NULL,
	[DataTypesID] [int] NOT NULL,
	[Description] [ntext] NULL
	CONSTRAINT [ExperimentID] FOREIGN KEY([ExperimentID]) REFERENCES [dbo].[Experiments] ([ID]) ON UPDATE CASCADE,
	CONSTRAINT [DataTypesID] FOREIGN KEY([DataTypesID]) REFERENCES [dbo].[DataTypes] ([ID]) ON UPDATE CASCADE
)
GO