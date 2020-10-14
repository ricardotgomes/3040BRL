/****** Object:  Table [dbo].[TB_BATCH_STATUS_VALIDACAO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_BATCH_STATUS_VALIDACAO](
	[ID_BATCH_STATUS_VALIDACAO] [int] IDENTITY(1,1) NOT NULL,
	[NOME_FUNDO] [varchar](1000) NULL,
	[NOME_VALIDACAO] [varchar](1000) NULL,
	[ID_BATCH_STATUS] [bigint] NULL,
 CONSTRAINT [PK__BATCH_STATUS_VALIDACAO] PRIMARY KEY CLUSTERED 
(
	[ID_BATCH_STATUS_VALIDACAO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[TB_BATCH_STATUS_VALIDACAO]  WITH CHECK ADD  CONSTRAINT [FK__BATCH_STATUS_VALIDACAO__BATCH_STATUS] FOREIGN KEY([ID_BATCH_STATUS])
REFERENCES [dbo].[TB_BATCH_STATUS] ([ID_BATCH_STATUS])
ON DELETE CASCADE
ALTER TABLE [dbo].[TB_BATCH_STATUS_VALIDACAO] CHECK CONSTRAINT [FK__BATCH_STATUS_VALIDACAO__BATCH_STATUS]