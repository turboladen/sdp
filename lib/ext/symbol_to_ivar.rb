class Symbol
  def to_ivar
    "@#{self}".to_sym
  end
end
