//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Anya on 28/07/2018.
//  Copyright © 2018 Anya Kundakchian. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        tableView.separatorStyle = .none
    }

    //MARK:- Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        //nil coalescing operator
        return categories?.count ?? 1
    }
    
    
    //Delegate method how we should display our cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //already a swipeable cell, inherits from superclass
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name ?? "No Categories added yet"
        
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            
            cell.backgroundColor = categoryColour
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
    }
    
    
     //MARK:- Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }

    //this method will be initialised just before that segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        let destinationVC = segue.destination as! TodoListViewController
        
        //going to identify the current row that is selected
        if let indexPath = tableView.indexPathForSelectedRow {
            
            //set selectedCategory property as current row (which is a selected category lol)
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
    
    
    //MARK:- Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        
        //forces tableView to call its data source methods again
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK:- Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categories?[indexPath.row] {

            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting a category \(error)")
            }

        }
        
    }
    
    
    //MARK:- Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //what will happen once the user clicks the add button on our UIAlert
            
            //create new Item object in the context -> fill up its fields -> save items (save the context, i.e. commit the temporary area
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        alert.addAction(action)
        
        //add text field to our alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        //show our alert
        present(alert, animated: true, completion: nil)
}
        
    }




























    

