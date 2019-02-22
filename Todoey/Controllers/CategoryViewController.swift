//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gio on 2/17/19.
//  Copyright © 2019 giomanveli. All rights reserved.
//

import UIKit
import RealmSwift
import CVCalendar

class CategoryViewController: SwipeTableViewController {
    
    private var shouldShowDaysOut = true
    private var animationFinished = true
    private var selectedDay: DayView!
    private var currentCalendar: Calendar?
    
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "fr_FR")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }

    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentCalendar = currentCalendar {
            
            monthLabel.title = CVDate(date: Date(), calendar: currentCalendar).globalDescription
            
        }
        
        // Menu delegate [Required]
        self.menuView.menuViewDelegate = self

        // Calendar delegate [Required]
        self.calendarView.calendarDelegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        

        viewDidLayoutSubviews()
        loadCategories()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
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
    
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    @IBOutlet weak var calendarView: CVCalendarView!

    @IBOutlet weak var monthLabel: UINavigationItem!
}

extension CategoryViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    // MARK: - Life cycle
    
    func presentationMode() -> CalendarMode { return .weekView }
    
    func firstWeekday() -> Weekday { return .monday }
    
    // MARK: Optional methods
    
    func calendar() -> Calendar? { return currentCalendar }
    
    func shouldShowWeekdaysOut() -> Bool { return shouldShowDaysOut }
    
    //MARK: Update Month Title
    
    func presentedDateUpdated(_ date: CVDate) {
        if monthLabel.title != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UINavigationItem()
            updatedMonthLabel.title = date.globalDescription
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.animationFinished = false
                //                self.monthLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                //                self.monthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                //                self.monthLabel.alpha = 0
                
                //                updatedMonthLabel.alpha = 1
                //                updatedMonthLabel.transform = CGAffineTransform.identity
                
            })
            { _ in
                
                self.animationFinished = true
                self.monthLabel.title = updatedMonthLabel.title
            }
        }
    }
    
    
    
    
    
    
//    func didShowNextMonthView(_ date: Date) {
//        guard let currentCalendar = currentCalendar else { return }
//
//        let components = Manager.componentsForDate(date, calendar: currentCalendar) // from today
//
//        print("Showing Month: \(components.month!)")
//    }
//
//    func didShowPreviousMonthView(_ date: Date) {
//        guard let currentCalendar = currentCalendar else { return }
//
//        let components = Manager.componentsForDate(date, calendar: currentCalendar) // from today
//
//        print("Showing Month: \(components.month!)")
//    }
//
//    func didShowNextWeekView(from startDayView: DayView, to endDayView: DayView) {
//        print("Showing Week: from \(startDayView.date.day) to \(endDayView.date.day)")
//    }
//
//    func didShowPreviousWeekView(from startDayView: DayView, to endDayView: DayView) {
//        print("Showing Week: from \(startDayView.date.day) to \(endDayView.date.day)")
//    }
}

