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
  out <- data.frame(
    'Rater' = raters, 'All' = NA, 'Survey1' = NA, 'Survey2' = NA,
    '#Disagree_Survey1' = NA, '#Concur_Survey1' = NA, '#Disagree_Survey2' = NA, '#Concur_Survey2' = NA,
    'Fisher_p-value' = NA, check.names = F, stringsAsFactors = F
  )
  for ( i in seq_along(raters) ) {
    idx <- df$Rater == raters[i]
    tbl <- table(df$Concur[idx], df$Survey[idx])
    fit <- fisher.test(as.matrix(tbl))
    out[i,-1] <- c(sum(tbl[2,])/sum(tbl), tbl[2,1]/sum(tbl[,1]), tbl[2,2]/sum(tbl[,2]), tbl, fit$p.value)
  }
  out <- rbind(
    out,
    c('mean', mean(out$All), mean(out$Survey1), mean(out$Survey2), NA, NA, NA, NA, NA),
    c('sd',     sd(out$All),   sd(out$Survey1),   sd(out$Survey2), NA, NA, NA, NA, NA)
  )
  write.csv(out, paste0('output/', annotation_type, '_mean_concordance_rater.csv'), row.names = F, na = '')

  # ------------------------------------------------------------
  # Annotation mean concordance
  # ------------------------------------------------------------
  
  annotations <- levels(df$Annotation)
  out <- data.frame(
    'Annotation' = annotations, 'All' = NA, 'Survey1' = NA, 'Survey2' = NA,
    '#Disagree_Survey1' = NA, '#Concur_Survey1' = NA, '#Disagree_Survey2' = NA, '#Concur_Survey2' = NA,
    'Fisher_p-value' = NA, check.names = F, stringsAsFactors = F
  )
  for ( i in seq_along(annotations) ) {
    idx <- df$Annotation == annotations[i]
    tbl <- table(df$Concur[idx], df$Survey[idx])
    fit <- fisher.test(as.matrix(tbl))
    out[i,-1] <- c(sum(tbl[2,])/sum(tbl), tbl[2,1]/sum(tbl[,1]), tbl[2,2]/sum(tbl[,2]), tbl, fit$p.value)
  }
  out <- rbind(
    out,
    c('mean', mean(out$All), mean(out$Survey1), mean(out$Survey2), NA, NA, NA, NA, NA),
    c('sd',     sd(out$All),   sd(out$Survey1),   sd(out$Survey2), NA, NA, NA, NA, NA)
  )
  write.csv(out, paste0('output/', annotation_type, '_mean_concordance_annotation.csv'), row.names = F, na = '')
  
}
