# ------------------------------------------------------------
# Data modification functions
# ------------------------------------------------------------

hitCalls <- function(df, annotation_field) {
  
  # Create all possible combinations for hit calls
  embryo     <- unique(df$Embryo_Number)
  annotation <- unique(df[, annotation_field])
  rater      <- unique(df$Rater)
  out <- data.frame(
    'Embryo'     = rep(embryo, each=length(rater)*length(annotation)),
    'Annotation' = rep(rep(annotation, each=length(rater)), length(embryo)),
    'Rater'      = rep(rater, length(annotation)*length(embryo)),
    'Call'       = 0,
    stringsAsFactors = F
  )
  
  # Fill in hit calls
  idx <- match(
    paste(df$Embryo_Number, df[, annotation_field], df$Rater),
    paste(out$Embryo, out$Annotation, out$Rater)
  )
  out$Call[idx] <- 1
  
  return(out)
}

filterData <- function(df, sameRaters = T, sameAnnotations = T) {
  
  # Keep raters that took both surveys
  if ( sameRaters ) {
    tbl <- table(df$Rater, df$Survey)
    rm_raters <- names(which(apply(tbl, 1, function(x) any(x == 0))))
    df <- df[!(df$Rater %in% rm_raters), ]
  }
  
  # Keep annotations that occur in both surveys
  if ( sameAnnotations ) {
    tbl <- table(df$Annotation, df$Survey)
    rm_annotations <- names(which(apply(tbl, 1, function(x) any(x == 0))))
    df <- df[!(df$Annotation %in% rm_annotations), ]
    if ( sameRaters ) {
      # If raters were removed, some annotations may have no hit calls anymore
      agg <- aggregate(df$Call, by = list(df$Survey, df$Annotation), sum)
      rm_annotations <- agg[agg[, 3] == 0, 2]
      df <- df[!(df$Annotation %in% rm_annotations), ]
    }
  }
  
  # Sort
  cols <- c('Survey', 'Embryo', 'Annotation', 'Rater', 'Call')
  df <- df[order(df$Survey, df$Embryo, df$Annotation, df$Rater),
           c(cols, names(df)[!(names(df) %in% cols)])]
  rownames(df) <- NULL
  
  return(df)
}

addConcurrence <- function(df) {
  
  # Determine majority hit calls
  agg <- setNames(
    aggregate(df$Call, by = list(df$Survey, df$Embryo, df$Annotation), function(x) round(mean(x))),
    c('Survey', 'Embryo', 'Annotation', 'MajorityCall')
  )
  
  # Add 'Concur' field, indicating if hit call is same as majority
  idx <- match(
    paste(df$Survey, df$Embryo, df$Annotation),
    paste(agg$Survey, agg$Embryo, agg$Annotation)
  )
  df$Concur <- as.integer(df$Call == agg$MajorityCall[idx])

  return(df)
}

# ------------------------------------------------------------
# Fleiss Kappa functions
# ------------------------------------------------------------

fleissTable <- function(df) {
  # Assumes all embryo-annotation combinations are present
  agg <- aggregate(
    df$Call,
    by = list(df$Embryo, df$Annotation),
    sum
  )
  tbl <- matrix(agg$x, nrow = length(unique(agg$Group.1)))
  rownames(tbl) <- unique(agg$Group.1)
  colnames(tbl) <- unique(agg$Group.2)
  return(tbl)
}

fleissKappa <- function(tbl) {
  pj <- 1/sum(tbl) * apply(tbl, 2, sum)
  n  <- apply(tbl, 1, sum)
  Pi <- 1/(n * (n-1)) * (apply(tbl, 1, function(x) sum(x^2)) - n)
  P  <- 1/nrow(tbl) * sum(Pi)
  Pe <- sum(pj^2)
  kappa <- (P - Pe) / (1 - Pe)
  return(list('pj'=pj, 'Pi'=Pi, 'P'=P, 'Pe'=Pe, 'kappa'=kappa))
}

fleissSave <- function(tbl, kappa, fn) {
  out <- rbind(
    tbl,
    'Total' = apply(tbl, 2, sum),
    'pj' = kappa$pj,
    rep(NA, ncol(tbl)),
    'kappa' = c(kappa$kappa, rep(NA, ncol(tbl) - 1))
  )
  out <- cbind(
    out,
    'Pi' = c(kappa$Pi,NA,NA,NA,NA)
  )
  write.csv(out, fn, na='')
}

if ( FALSE ) {
  # Example from wiki page (https://en.wikipedia.org/wiki/Fleiss%27_kappa)
  fleissKappa(matrix(c(
    0,0,0,0,14,
    0,2,6,4,2,
    0,0,3,5,6,
    0,3,9,2,0,
    2,2,8,1,1,
    7,7,0,0,0,
    3,2,6,3,0,
    2,5,3,2,2,
    6,5,2,1,0,
    0,2,2,3,7
  ), nrow=10, byrow=T))
}
