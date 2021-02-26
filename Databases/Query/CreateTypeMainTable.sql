USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE [dbo].[SpecimenProperty]
GO


CREATE TABLE [dbo].[SpecimenProperty](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[SpecimenID] [int] NOT NULL,
	[Property] [char] NULL,
	[Value] [char] NULL,
	[Type] [char] NULL,
 CONSTRAINT [SpecimenID] FOREIGN KEY([SpecimenID]) REFERENCES [dbo].[Specimens] ([ID]) ON DELETE CASCADE)
GO