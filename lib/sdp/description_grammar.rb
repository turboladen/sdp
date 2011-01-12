grammar SDPDescription
	rule description
		session_section media_section
	end

  rule session_section
		#"v=" /.*(?=m=)/
		~/m\=/
	end

	rule media_section
		.*
	end
end