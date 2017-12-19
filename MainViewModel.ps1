Class MainViewModel 
{
       [PersonViewModel] $Person 
       [BackgroundViewModel] $Background

        MainViewModel()
        {
            $this.Person = [PersonViewModel]::new()
            $this.Background = [BackgroundViewModel]::new()
        }

        SetBackground([System.Windows.Media.Brush] $brushColor)
        {
            $this.Background.Color = $brushColor;
        }

        [String] ToString() 
        {
            return $this.Person.name
        }
}

    