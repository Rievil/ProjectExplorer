USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE [dbo].[Meas]
GO

CREATE TABLE [dbo].[Meas](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ExpID] [int] NOT NULL,
	[Datetime] [datetime] NULL,
	[SpecCount] [int] NULL,
	[MasterFolder] [char] NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [ExpID] FOREIGN KEY([ExpID]) REFERENCES [dbo].[Experiments] ([ID]) ON DELETE CASCADE)
GO