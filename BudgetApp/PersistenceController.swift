//
//  PersistenceController.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import CoreData

@objc(ExpenseEntity)
final class ExpenseEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var category: String
    @NSManaged var amount: Double
    @NSManaged var date: Date
}

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var context: NSManagedObjectContext { container.viewContext }

    private static let model: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "ExpenseEntity"
        entity.managedObjectClassName = NSStringFromClass(ExpenseEntity.self)

        func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = false
            return attribute
        }

        entity.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("name", .stringAttributeType),
            attribute("category", .stringAttributeType),
            attribute("amount", .doubleAttributeType),
            attribute("date", .dateAttributeType)
        ]
        model.entities = [entity]
        return model
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BudgetApp", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
