$code = @'
using System.ComponentModel;

public class ObservableObject : INotifyPropertyChanged
{
    public event PropertyChangedEventHandler PropertyChanged;

    protected void OnPropertyChanged(string name)
    {
        if (PropertyChanged != null)
        {
            PropertyChanged(this, new PropertyChangedEventArgs(name));
        }
    }
}

public class PersonViewModel : ObservableObject
{
    private string _name;
    public string Name
    {
        get
        {
            if (string.IsNullOrEmpty(_name))
                return "Unknown";
            return _name;
        }
        set
        {
            _name = value;
            OnPropertyChanged("Name");
        }
    }
}

'@

Add-Type $code

<#$source = @'
public class PersonViewModel : ObservableObject
{
    private string _name;
    public string Name
    {
        get
        {
            if (string.IsNullOrEmpty(_name))
                return "Unknown";
            return _name;
        }
        set
        {
            _name = value;
            OnPropertyChanged("Name");
        }
    }
}
'@
Add-Type $source


<#    add_PropertyChanged() {
        $this.PropertyChanged
    } #>
#>