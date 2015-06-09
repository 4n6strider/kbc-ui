outputTableSuffixes =
  'geneea-topic-detection': 'topic'
  'geneea-sentiment-analysis': 'sentiment'
  'geneea-lemmatization': 'lemma'
  'geneea-text-correction': 'correction'
  'geneea-language-detection': 'lang'

tooltips  =
  'geneea-topic-detection':
    intable: "Table containing text for topic detection"
    data_column: "Column of the input table containing text for topic detection"
    id_column: "Column of the input table uniquely identifying each row of the input table"
    outtable: "Result table containing columns id(primary key column values),\
     topic and confidence column as a result of topic detection of data column"

  'geneea-sentiment-analysis':
    intable: "Table containing text for sentiment analysis"
    data_column: "Column of the input table containing text for sentiment analysis"
    id_column: "Column of the input table uniquely identifying each row of the input table"
    outtable: "Result table containing columns id(primary key column values) and \
     sentiment column as a result of sentiment analysis of data column"

  'geneea-lemmatization':
    intable: "Table containing text for lemmatization"
    data_column: "Column of the input table containing text for lemmatization"
    id_column: "Column of the input table uniquely identifying each row of the input table"
    outtable: "Result table containing columns id(primary key column values),\
     lemma and lemmaIndex column as a result of lemmatization of data column"

  'geneea-text-correction':
    intable: "Table containing text for text correction"
    data_column: "Column of the input table containing text for text correction"
    id_column: "Column of the input table uniquely identifying each row of the input table"
    outtable: "Result table containing columns id(primary key column values),\
     correctedText, isCorrected and isDiacritized column as a result of text correction of data column"

  'geneea-language-detection':
    intable: "Table containing text for language detection"
    data_column: "Column of the input table containing text for language detection"
    id_column: "Column of the input table uniquely identifying each row of the input table"
    outtable: "Result table containing columns id(primary key column values)\
     and language column as a result of language detection of data column"


module.exports = (componentId) ->
  tooltips: tooltips[componentId] or {}
  outputTableSuffix: outputTableSuffixes[componentId] or "ex"