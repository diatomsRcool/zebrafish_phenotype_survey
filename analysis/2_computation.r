rm(list=ls())
source('0_functions.r')
library('rptR')

for (annotation_type in c('general', 'granular')) {

  df <- read.csv(paste0('data/formatted_data_', annotation_type, '.csv'), stringsAsFactors = F)
  df <- filterData(df)
  df <- addConcurrence(df)
  
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

  fit <- glm(Concur ~ Survey + Embryo + Annotation + Rater, data = df, family = 'binomial')
  sink(paste0('output/', annotation_type, '_glm.txt'))
  print(summary(fit))
  sink()

  # ------------------------------------------------------------
  # Rater mean concordance
  # ------------------------------------------------------------
  
  raters <- levels(df$Rater)
  raterMeanConcordance <- setNames(cbind(
    raters,
    data.frame(do.call(rbind, lapply(raters, function(x) {
      c(mean(df$Concur[df$Rater == x]),
        mean(df$Concur[df$Rater == x & df$Survey == 1]),
        mean(df$Concur[df$Rater == x & df$Survey == 2]))
    })))
  ), c('Rater', 'All', 'Survey1', 'Survey2'))
  raterMeanConcordance <- rbind(
    raterMeanConcordance,
    c('mean', mean(raterMeanConcordance$All), mean(raterMeanConcordance$Survey1), mean(raterMeanConcordance$Survey2)),
    c('sd',     sd(raterMeanConcordance$All),   sd(raterMeanConcordance$Survey1),   sd(raterMeanConcordance$Survey2))
  )
  write.csv(raterMeanConcordance, paste0('output/', annotation_type, '_mean_concordance_rater.csv'), row.names = F)

  # ------------------------------------------------------------
  # Annotation mean concordance
  # ------------------------------------------------------------
  
  annotations <- levels(df$Annotation)
  annotMeanConcordance <- setNames(cbind(
    annotations,
    data.frame(do.call(rbind, lapply(annotations, function(x) {
      c(mean(df$Concur[df$Annotation == x]),
        mean(df$Concur[df$Annotation == x & df$Survey == 1]),
        mean(df$Concur[df$Annotation == x & df$Survey == 2]))
    })))
  ), c('Annotation', 'All', 'Survey1', 'Survey2'))
  annotMeanConcordance <- rbind(
    annotMeanConcordance,
    c('mean', mean(annotMeanConcordance$All), mean(annotMeanConcordance$Survey1), mean(annotMeanConcordance$Survey2)),
    c('sd',     sd(annotMeanConcordance$All),   sd(annotMeanConcordance$Survey1),   sd(annotMeanConcordance$Survey2))
  )
  write.csv(annotMeanConcordance, paste0('output/', annotation_type, '_mean_concordance_annotation.csv'), row.names = F)
  
}
