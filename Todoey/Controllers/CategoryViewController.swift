//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gio on 2/17/19.
//  Copyright © 2019 giomanveli. All rights reserved.
//

import UIKit
import RealmSwift
import CalendarKit

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    
    //MARK: TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name  ?? "No categories added yet"
        
        return cell
        
    }
    
    //MARK: Add New Categories
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        //Add Button
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //What happens once user press add item button on UIAlert
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK:  TableView Delegate Methods - what should happen when we click on one of the cells
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            
            
        }
    }
    
    
    //MARK: Data Manipulation Methods
    func save(category: Category) {
        
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategories() {
        
       categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    //MARK: Delete  Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        //Upate data model
        
                    if let categoryForDeletion = self.categoryArray?[indexPath.row] {
        
                        do {
                            try self.realm.write {
                                self.realm.delete(categoryForDeletion)
                            }
                        } catch {
                            print("Error saving done status \(error)")
                        }
        
                    }
    }
    
}
