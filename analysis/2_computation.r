rm(list=ls())
source('0_functions.r')
library('rptR')

for (annotation_type in c('general', 'granular')) {

  df <- read.csv(paste0('data/formatted_data_', annotation_type, '.csv'), stringsAsFactors = F)
  df <- filterData(df)

  # Factor categorical variables
  df$Survey     <- factor(df$Survey)
  df$Embryo     <- factor(df$Embryo)
  df$Rater      <- factor(df$Rater)
  df$Annotation <- factor(df$Annotation)
  
  # ------------------------------------------------------------
  # Fleiss Kappa
  # Embryos can be in multiple categories, is that a problem for stats calc?
  # ------------------------------------------------------------
  
  for (survey in 1:2) {
    tbl   <- fleissTable(df[df$Survey == survey, ])
    kappa <- fleissKappa(tbl)
    fleissSave(tbl, kappa, paste0('output/', annotation_type, '_fleissKappa_survey', survey, '.csv'))
  }
  
  # ------------------------------------------------------------
  # Intraclass correlation
  # ------------------------------------------------------------

  for (survey in 1:2) {
    icc <- rpt(
      Call ~ (1 | Embryo) + (1 | Annotation) + (1 | Rater),
      grname = c('Embryo', 'Annotation', 'Rater'),
      data = df[df$Survey == survey, ],
      datatype = 'Binary',
      nboot = 500,
      npermut = 0
    )
    sink(paste0('output/', annotation_type, '_icc_survey', survey, '.txt'))
    print(summary(icc))
    sink()
    pdf(paste0('output/', annotation_type, '_icc_survey', survey, '.pdf'), height = 7, width = 7)
    layout(matrix(1:3))
    plot(icc, grname = 'Embryo',     type = 'boot')
    plot(icc, grname = 'Annotation', type = 'boot')
    plot(icc, grname = 'Rater',      type = 'boot')
    invisible(dev.off())
  }

  # ------------------------------------------------------------
  # Fit glm
  # ------------------------------------------------------------
  
  df <- addConcurrence(df)
  fit <- glm(Concur ~ Survey + Embryo + Annotation + Rater, data = df, family = 'binomial')
  sink(paste0('output/', annotation_type, '_glm.txt'))
  print(summary(fit))
  sink()
  
}
