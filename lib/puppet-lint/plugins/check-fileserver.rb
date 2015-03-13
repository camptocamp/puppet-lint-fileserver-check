PuppetLint.new_check(:fileserver) do
  def check
    resource_indexes.each do |resource|
      if resource[:type].value == 'file'
        attr = resource[:tokens].select { |t| t.type == :NAME && \
                                          t.value == 'source' && \
                                          t.next_code_token.type == :FARROW }
        next if attr.empty?
        notify :warning, {
          :message  => 'expected file() instead of fileserver',
          :line     => attr[0].line,
          :column   => attr[0].column,
          :token    => attr[0],
          :resource => resource,
        }
      end
    end
  end

  def fix(problem)
    problem[:token].value = 'content'
    file = problem[:token].next_code_token.next_code_token
    if file.type == :DQPRE
      file.value.sub!(/puppet:\/\/\/modules\/(.*)/, "file(")
    else
      file.value.sub!(/puppet:\/\/\/modules\/(.*)/, "file('\\1')")
    end
    file.type = :NAME
  end
end
