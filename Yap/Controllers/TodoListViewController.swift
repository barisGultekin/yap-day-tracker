//
//  ViewController.swift
//  Yap
//
//  Created by Ali Barış Gültekin on 25.04.2021.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController
{
    var selectedCategory: Category?
    {
        didSet
        {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBar.delegate = self
        loadItems()
        title = selectedCategory!.name!
    }
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done == true ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Item Actions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") //try '􀈒' on physical device!
        { (action, view, completionHandler) in
            self.deleteItem(at: indexPath.row)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    //MARK: - Add Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField = UITextField()
        
        let alert = UIAlertController(
            title: "Add new task",
            message: "Please specify your task",
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default)
        { (addAction) in
            if textField.text != ""
            {
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                
                self.saveItems()
                
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField
        { (alertTextField) in
            alertTextField.placeholder = "Your task"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CRUD
    
    func saveItems()
    {
        do
        {
            try self.context.save()
        }
        catch
        {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(for keyword: String = "")
    {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if keyword == ""
        {
            request.predicate = categoryPredicate
        }
        else
        {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", keyword)
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [categoryPredicate, searchPredicate])
        }
        
        do
        {
            itemArray = try context.fetch(request)
        }
        catch
        {
            print("Error fetching items\(error)")
        }
        tableView.reloadData()
    }
    
    func deleteItem(at index: Int)
    {
        context.delete(itemArray[index])
        itemArray.remove(at: index)
        saveItems()
    }
}

//MARK: - Search Bar
extension TodoListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        let keyword = searchBar.text!
        loadItems(for: keyword)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.count == 0
        {
            loadItems()
            
            DispatchQueue.main.async
            {
                searchBar.resignFirstResponder()
            }
        }
        else
        {
            let keyword = searchBar.text!
            loadItems(for: keyword)
        }
    }
}

