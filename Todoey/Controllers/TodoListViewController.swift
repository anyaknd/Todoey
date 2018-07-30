//
//  ViewController.swift
//  Todoey
//
//  Created by Anya on 25/07/2018.
//  Copyright © 2018 Anya Kundakchian. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        //as soon as we have a value for selectedCategory - load items
        didSet{
            loadItems()
        }
    }
    
    //now have access to AppDelegate. Able to tap into its persistentContainer property. Able to view Context of that persistent Container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }
    
    //MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //Delegate method how we should display our cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //set up a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let currentItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = currentItem.title
        
        //Ternary operator
        //value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = currentItem.done == true ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK:- Tableview Delegate Methods
    
    //this method detects which cell was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //current item object selected - sets done property is the opposite of what it was before
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK:- Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //what will happen once the user clicks the add button on our UIAlert
            
            
            //create new Item object in the context -> fill up its fields -> save items (save the context, i.e. commit the temporary area
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        alert.addAction(action)
        
        //add text field to our alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Todoey"
            textField = alertTextField
        }
        
        //show our alert
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Model Manipulating Methods
    
    func saveItems() {

        do {
            try context.save()
        } catch {
            print(error)
        }
        
        //forces tableView to call its data source methods again
        self.tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
   
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
       
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        //fetch our request
        do {
        itemArray = try context.fetch(request)
        } catch {
            print("Load items error \(error)")
        }
    }
    

}

//MARK:- Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            //run this method, of disappearing search bar when we dismiss it, on the main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        
        }
    }
    
}



















