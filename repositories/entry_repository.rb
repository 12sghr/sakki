class EntryRepository
  def initialize
    @entries = []
  end
  def save(entry)
    # なんか保存
    @entries.push(entry)
    return @entries.length - 1
  end

  def fetch(id)
    @entries[id]
  end
end
