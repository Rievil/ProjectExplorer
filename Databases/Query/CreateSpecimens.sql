USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE [dbo].[Specimens]
GO
*/
CREATE TABLE [dbo].[Specimens](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[MeasID] [int] NOT NULL,
	[Name] [char] NULL,
	[Commentary] [char] NULL,
	[UserDefinedProperty] [char] NULL,
 CONSTRAINT [MeasID] FOREIGN KEY([MeasID]) REFERENCES [dbo].[Meas] ([ID]) ON DELETE CASCADE)
GO