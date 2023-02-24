class City < ApplicationRecord
  #belongs_to :user
  # TODO PrefectureとCityの制約については、後回し（実装の仕方が大きく変更される可能性があるため。）
  # TODO 型をbigintに変更し、外部キー制約を持つようにする。
end
