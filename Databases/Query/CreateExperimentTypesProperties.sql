USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE [dbo].[Experiments]
Go
*/


CREATE TABLE [dbo].[ExperimentTypesProperties](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ExperimentTypesID] [int] NOT NULL,
	[DataTypesPropertiesID] [int] NOT NULL,
	[Name] [ntext] NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [ExperimentTypesID] FOREIGN KEY([ExperimentTypesID]) REFERENCES [dbo].[ExperimentTypes] ([ID]) ON DELETE CASCADE,
 CONSTRAINT [DataTypesPropertiesID] FOREIGN KEY([DataTypesPropertiesID]) REFERENCES [dbo].[DataTypesProperties] ([ID]) ON DELETE CASCADE)
GO