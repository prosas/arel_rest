# TODO: Resolver para o caso de ordenação por colunas de tabelas associadas

# Adpta objeto json para hash de consulta compativél com o active_record
## Como usar
# Inclua o module include JsonApiFilterAdapter na controller.
# chame o método parse_filter_adapter(params)
# ```
# class Controller < ApplicationControllers
#  Model.where(parse_filter_adapter(params))
#	 ...
# end
# ```
# TODO: Extrair para uma gem
# TODO: Resolver para o caso de ordenação por colunas de tabelas associadas
require 'byebug'
module JsonApiFilterAdapter
  VALUE = 1
  KEY = 0
  # Adpta objeto jsonvpara hash de consulta compativél com o active_record
  # Ex:
  # >> object_json_api = "{id: 1, data: 01/01/2022..31/01/2022}"
  # >> adpter_from_json_api_to_active_record(object_json_api)
  # >> {"id": 1, "data": Range(Date.parse("01/01/2022"), Date.parse("31/01/2022"))}
  def parse_filter_adapter(data)
    # data = data_order_formater data, params

    data_parsed = {}
    data.each do |parameter|
      # verifica se valor do filtro é um range
      next unless parameter[VALUE].to_s.include?('..')

      first, last = parameter[VALUE].split('..')
      case parameter[VALUE]
      when /^\d{4}-\d{2}-\d{2}..\d{4}-\d{2}-\d{2}$/
        data_parsed[parameter[KEY]] = Range.new(Date.parse(first), Date.parse(last))
      when /^\d+..\d+$/
        data_parsed[parameter[KEY]] = Range.new(first.to_i, last.to_i)
      when /^\d+.\d+..\d+.\d+$/
        data_parsed[parameter[KEY]] = Range.new(first.to_d, last.to_d)
      end
    end

    data.merge(data_parsed)

    operator_parser_hash_to_array data
  end

  private

  def operator_parser_hash_to_array(data)
    data_converted_value = []
    data_converted_header = ''
    cont = 1

    # interar o data para analisar isoladamente cada chave vs valor
    data.each do |parameter|
      # tratar operador de comparação
      value_downcase = parameter[VALUE].to_s.downcase

      if value_downcase.include?('=like=')
        conditional_operator = ':value LIKE ?'
        parameter[VALUE] = "%#{parameter[VALUE]}%"
      elsif parameter[VALUE].to_s.include?('..')
        conditional_operator = ':value BETWEEN ? AND ?'
      elsif parameter[VALUE].is_a?(Array) & !value_downcase.include?('=null=')
        conditional_operator = ':value IN (?)'
      elsif parameter[VALUE].is_a?(Array) && value_downcase.include?('=null=')
        parameter[VALUE] = parameter[VALUE].filter { |v| v != '=null=' }
        conditional_operator = "(:value IS NULL OR :value IN (?))"
      elsif !parameter[VALUE].is_a?(Array) && value_downcase.include?('=null=')
        parameter[VALUE] = nil
        conditional_operator = ':value IS NULL'
      else
        conditional_operator = ':value = ?'
      end

      # tratar operador de pesquisa
      query_conditional_operator = value_downcase.include?('=or=') ? 'OR' : 'AND'
      # criar a 1º string do vetor que carrega o corpo da pesquisa
      # saber se esta no final da lista de parametros
      if cont < data.to_hash.size
        # se não tiver no final da lista
        data_converted_header = data_converted_header + " " + "#{conditional_operator} #{query_conditional_operator}".gsub(":value", parameter[KEY])
        cont += 1
      else
        # se tiver no final da lista
        data_converted_header = data_converted_header + " " + "#{conditional_operator}".gsub(":value", parameter[KEY])
        cont += 1
      end
    end
    data_converted_header.strip!

    # criar os demais elementos do vetor que faram referencia em ordem a cada um dos pontos de interrogação
    data.to_hash.each_value do |value|
      # tratando entradas que não são arrays
      unless value.is_a?(Array)

        value_modificad = value.to_s.downcase
        # tratar like e or
        if value_modificad.include?('=like=')
          value_modificad.slice! '=like='
          value_modificad = "%#{value_modificad}%"
        end
        value_modificad.slice! '=or=' if value_modificad.include?('=or=')
        if value_modificad.include?('true') || value_modificad.include?('false')
          data_converted_value << value_modificad.to_bool
        elsif !value_modificad.include?('=null=')
          # tratar between
          if value_modificad.include?('..')
            first, last = value_modificad.split('..')
            data_converted_value << first
            data_converted_value << last
          end
          data_converted_value << value_modificad unless value_modificad.include?('..')
        end
      end
      # tratando entradas que são array
      data_converted_value << value.filter { |v| v != '=null=' } if value.is_a?(Array)
    end

    # montar array de busca , primeira posição string query , segunda posição ate N serão parametros
    data_converted_value.unshift(data_converted_header)
    data_converted_value
  end
end