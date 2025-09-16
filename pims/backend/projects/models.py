from django.db import models

class Project(models.Model):
    name = models.CharField(max_length=200)
    sector = models.CharField(max_length=100)
    budget = models.DecimalField(max_digits=15, decimal_places=2)
    start_date = models.DateField()
    end_date = models.DateField()

    def __str__(self):
        return self.name
