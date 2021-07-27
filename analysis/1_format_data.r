rm(list=ls())
source('0_functions.r')

annotations <- list(
  'general'  = 'General_Annotation_CURIE',
  'granular' = 'Granular_Annotation_CURIE'
)

# ------------------------------------------------------------
# Load data
# ------------------------------------------------------------

dfs <- list(
  read.delim('../Zebrafish_Screening_Survey_1_summary_by_annotator.tsv'),
  read.delim('../Zebrafish_Screening_Survey_2_summary_by_annotator.tsv')
)

# Look at fields
lapply(dfs, function(df) {sort(unique(df[, 'Embryo_Number']))})
(raters <- lapply(dfs, function(df) {sort(unique(df[, 'Participant_Identifier']))}))
for (annotation in annotations) {
  print(lapply(dfs, function(df) {sort(unique(df[, annotation]))}))
}

# Use embryo numbering from survey 2
embryo_map <- read.delim('../embryo_image_map.tsv')
dfs[[1]]$Embryo_Number <- embryo_map[match(dfs[[1]]$Embryo_Number, embryo_map[, 2]), 1]

# Label raters
# The initial analysis had it's own anonymize step since it
# was done before data was anonymized. Now that data is also
# anonymized, remap to match origianl analysis labels.
raters_map <- cbind(1:18, c(5, 12, 11, 13, 17, 15, 6, 4, 14, 9, 8, 2, 3, 1, 7, 18, 10, 16))
for (i in 1:length(dfs)) {
  dfs[[i]]$Rater <- sprintf('R%02d', raters_map[match(dfs[[i]]$Participant_Identifier, raters_map[, 1]), 2])
}

# ------------------------------------------------------------
# Format data
# ------------------------------------------------------------

for (annotation_type in names(annotations)) {
  
  # Convert to hit calls
  hit_calls <- lapply(dfs, hitCalls, annotation_field = annotations[[annotation_type]])
  
  # Combine both surveys
  hit_calls[[1]]$Survey <- 1
  hit_calls[[2]]$Survey <- 2
  df <- do.call(rbind, hit_calls)
  df <- df[order(df$Survey, df$Embryo, df$Annotation, df$Rater),
           c('Survey', 'Embryo', 'Annotation', 'Rater', 'Call')]
  fn <- paste0('data/formatted_data_', annotation_type, '.csv')
  write.csv(df, fn, row.names = F, quote = F)
}
