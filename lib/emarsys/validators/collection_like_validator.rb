class CollectionLikeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << 'is not a collection' unless value.respond_to?(:each)
  end
end
