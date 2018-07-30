//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Anya on 28/07/2018.
//  Copyright © 2018 Anya Kundakchian. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    //MARK:- Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    //Delegate method how we should display our cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //set up a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let currentCategory = categories[indexPath.row]
        
        cell.textLabel?.text = currentCategory.name
        
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
            destinationVC.selectedCategory = categories[indexPath.row]
        }
        
    }
    
    
    //MARK:- Data Manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        //forces tableView to call its data source methods again
        self.tableView.reloadData()
        
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Load category error \(error)")
        }
    }
    
    
    //MARK:- Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //what will happen once the user clicks the add button on our UIAlert
            
            //create new Item object in the context -> fill up its fields -> save items (save the context, i.e. commit the temporary area
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
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
    




























    

