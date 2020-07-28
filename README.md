# Zebrafish Endpoint Phenotype Survey
## Introduction
Zebrafish are a key animal model for toxicology because they are easily maintained and bred in the laboratory, they have rapid, easily observed development, and their embryos are not subject to the Public Health Service Policy on Humane Care and Use of Laboratory Animals. Labs engaged in high-throughput analyses have established handbooks to internally standardize results, but these standards are rarely applied across laboratories. This lack of widely accepted reporting standard poses a problem for integrating and comparing data across labs, which is necessary for more robust corroboration in the confidence of results from toxicological assessments. Biological ontologies have demonstrated their effectiveness as data integration infrastructure and are a potential solution. 
To explore this possibility, we tested the hypothesis that providing ontology terms would improve the consistency of endpoint reporting in high-throughput zebrafish embryo assays. This repo contains the resulting data.
## Methods
We tested our hypothesis using two surveys.
### Survey Participants
Survey participants were solicited via email from the professional networks of the authors. A total of 18 people from 14 government and academic research laboratories in multiple countries (Europe and North America) participated in at least one of the two surveys. Every participant worked in a zebrafish lab with protocols for endpoint reporting. 
### Surveys and Data Files
Participants were asked to take two surveys. The first survey was a Google Form with 24 lateral images each with a single zebrafish embryo from the VAST (Vertebrate Automates Screening Technology)-System. In the first survey, participants were instructed to annotate each image with toxicological endpoints as they would in their lab and were provided with a free text response box. Participants were asked to separate individual endpoints with a semicolon. The second survey was a Google Spreadsheet with the same 24 images in a different order. Participants were provided with a multiple-choice list of 48 ontology terms and their definitions and were instructed to choose all that applied. Participants were instructed to indicate if a desired term was not available.
The ontology terms provided in survey 2 were selected from the endpoint annotations in survey 1. Each endpoint annotation was matched with as specific an ontology term as possible from ZPO. All of the matching was performed by one person. Each endpoint was also categorized using a more general term for analysis. For example, a heart edema endpoint was transformed to an abnormal heart endpoint for the general term calculations. Each survey contained some normal embryos.
#### Survey 1 Data
The results from survey 1 are in *Zebrafish_Screening_Survey_1_summary_by_annotator.tsv*. 

| Column Header | Definition | Values |
| ------------- | ---------- | ------ |
| Participant_Identifier | Anonymized identifier for survey participants | Integer 1-18 |
| Embryo_Number | Unique identifier for each embryo image | Integer 1-26 |
| Verbatim_Annotation | Free-text response from participant | Alphanumeric string |
| Granular_Annotation_CURIE | Identifier from an ontology that most closely describes the free-text annotation | Can include "normal" or CURIE from Zebrafish Phenotype Ontology |
| General_Annotation_CURIE | Identifier from an ontology for the category of endpoint observed | Can include "normal" or CURIE from Zebrafish Phenotype Ontology |

The results from survey 2 are in *Zebrafish_Screening_Survey_2_summary_by_annotator.tsv*.

| Column Header | Definition | Values |
| ------------- | ---------- | ------ |
| Participant_Identifier | Anonymized identifier for survey participants | Integer 1-18 |
| Embryo_Number | Unique identifier for each embryo image | Integer 1-26 |
| Granular_Annotation_CURIE | Identifier from an ontology that most closely describes the free-text annotation | Can include "normal" "Not Available" or CURIE from Zebrafish Phenotype Ontology |
| General_Annotation_CURIE | Identifier from an ontology for the category of endpoint observed | Can include "normal" "Not Available" or CURIE from Zebrafish Phenotype Ontology |

The embryos were assigned different numbers in surveys 1 and 2. The mapping for those numbers is in *embryo_image_map.tsv*

| Column Header | Definition | Values |
| ------------- | ---------- | ------ |
| Embryo_Number_Survey_2 | Unique identifier for each embryo image | Integer 1-26 |
| Embryo_Number_Survey_1 | Unique identifier for each embryo image | Integer 1-26 |

The mapping between general and granular terms and the CURIES and definitions are in *ZP_term_definitions.tsv*.

| Column Header | Definition | Values |
| ------------- | ---------- | ------ |
| general_term | human-readable label for general term | Alphanumeric string |
| granular_term | human-readable label for granular term | Alphanumeric string |
| ZPO_CURIE | corresponding CURIE from Zebrafish Phenotype Ontology | URI |
| definition | definition of term from Zebrafish Phenotype Ontology | Alphanumeric string |
