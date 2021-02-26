USE Projects
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[ProjectList](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ProjectName] [ntext] NULL,
	[Description] [ntext] NULL,
	[ProjectStart] [datetime] NULL,
	[ProjectEnd] [datetime] NULL,
	[LastChange] [datetime] NULL
)
GO

CREATE TABLE [dbo].[Experiments](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ProjectID] [int] NOT NULL,
	[Name] [ntext] NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [ProjectID] FOREIGN KEY([ProjectID]) REFERENCES [dbo].[ProjectList] ([ID]) ON UPDATE CASCADE)
GO

CREATE TABLE [dbo].[DataTypes](
	[ID] [int] NOT NULL PRIMARY KEY,
	[Name] [ntext] NULL,
	[Description] [ntext] NULL
)
GO

CREATE TABLE [dbo].[Users](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Alias] [char] NULL,
	[UserName] [char] NULL,
	[Password] [char] NULL)
GO

CREATE TABLE [dbo].[UsersPC](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[UserID] [int] NOT NULL,
	[PCName] [char] NULL,
	[MasterFolder] [char] NULL,
	[SandboxFolder] [char] NULL,
	CONSTRAINT [UserID] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([ID]) ON DELETE CASCADE)
GO

CREATE TABLE [dbo].[UserStatus](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Name] [char] NULL)
GO

CREATE TABLE [dbo].[UsersOnProjects](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[StatusID] [int] NOT NULL,
	[ProjectUserID] [int] NOT NULL,	
	CONSTRAINT [ProjectUserID] FOREIGN KEY([ProjectUserID]) REFERENCES [dbo].[Users] ([ID]) ON DELETE CASCADE,
	CONSTRAINT [StatusID] FOREIGN KEY([StatusID]) REFERENCES [dbo].[UserStatus] ([ID]) ON DELETE CASCADE)
GO


CREATE TABLE [dbo].[DataTypesProperties](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[DataTypeID] [int] NOT NULL,
	[Property] [varchar] NOT NULL,
	[Value] [varchar] NULL,
	[Type] [varchar] NULL,
 CONSTRAINT [DataTypeID] FOREIGN KEY([DataTypeID]) REFERENCES [dbo].[DataTypes] ([ID]) ON DELETE CASCADE)
GO

CREATE TABLE [dbo].[ExperimentTypes](
	[ID] [int] NOT NULL PRIMARY KEY,
	[ExperimentID] [int] NOT NULL,
	[DataTypesID] [int] NOT NULL,
	[Description] [ntext] NULL
	CONSTRAINT [ExperimentID] FOREIGN KEY([ExperimentID]) REFERENCES [dbo].[Experiments] ([ID]) ON UPDATE CASCADE,
	CONSTRAINT [DataTypesID] FOREIGN KEY([DataTypesID]) REFERENCES [dbo].[DataTypes] ([ID]) ON UPDATE CASCADE
)
GO

CREATE TABLE [dbo].[ExperimentTypesProperties](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ExperimentTypesID] [int] NOT NULL,
	[DataTypesPropertiesID] [int] NOT NULL,
	[Name] [ntext] NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [ExperimentTypesID] FOREIGN KEY([ExperimentTypesID]) REFERENCES [dbo].[ExperimentTypes] ([ID]) ON DELETE CASCADE,
 CONSTRAINT [DataTypesPropertiesID] FOREIGN KEY([DataTypesPropertiesID]) REFERENCES [dbo].[DataTypesProperties] ([ID]) ON DELETE CASCADE)
GO

CREATE TABLE [dbo].[Meas](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ExpID] [int] NOT NULL,
	[Datetime] [datetime] NULL,
	[SpecCount] [int] NULL,
	[MasterFolder] [ntext] NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [ExpID] FOREIGN KEY([ExpID]) REFERENCES [dbo].[Experiments] ([ID]) ON DELETE CASCADE)
GO

CREATE TABLE [dbo].[Specimens](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[MeasID] [int] NOT NULL,
	[Name] [char] NULL,
	[Commentary] [char] NULL,
	[UserDefinedProperty] [char] NULL,
 CONSTRAINT [MeasID] FOREIGN KEY([MeasID]) REFERENCES [dbo].[Meas] ([ID]) ON DELETE CASCADE)
GO

CREATE TABLE [dbo].[SpecimenProperty](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[SpecimenID] [int] NOT NULL,
	[Property] [char] NULL,
	[Value] [char] NULL,
	[Type] [char] NULL,
 CONSTRAINT [SpecimenID] FOREIGN KEY([SpecimenID]) REFERENCES [dbo].[Specimens] ([ID]) ON DELETE CASCADE)
GO