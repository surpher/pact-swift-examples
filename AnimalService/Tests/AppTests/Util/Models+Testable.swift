@testable import App
import Fluent
import Foundation

extension Species {

	@discardableResult
	static func create(
		id: UUID? = nil,
		name: String = "Marion",
		on database: Database
	) throws -> Species {
		let species = Species(id: id, name: name)
		try species.save(on: database).wait()

		return species
	}

}

extension Animal {

	@discardableResult
	static func create(
		id: UUID? = nil,
		name: String = "Gweneth",
		age: Int = 42,
		speciesID: Species.IDValue,
		on database: Database
	) throws -> Animal {
		if let id = id {
			_ = Animal.query(on: database)
				.filter(\.$id == id)
				.delete()
		}

		let animal = Animal(id: id, name: name, age: age, speciesID: speciesID)
		try animal.save(on: database).wait()

		return animal
	}

}
