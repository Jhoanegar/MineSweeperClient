class String
  def remove_parenthesis
    self.gsub!(/[\(\)]/,"")
  end
end
