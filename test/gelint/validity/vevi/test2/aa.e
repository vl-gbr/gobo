class AA

create

	make

feature

	make
		local
			a: detachable ANY
		do
			a := f
		end
		
	f: attached STRING
		local
			a: detachable ANY
		do
			a := Result
			Result := "gobo"
		end
		
end
