json.array!(@expertises) do |expertise|
  json.extract! expertise, :id
  json.url expertise_url(expertise, format: :json)
end
