'''
This file is a test for shared mpi4py libraries in a cluster environment.
The application can be run...
'''
__author__ = 'Fernando Demarchi Natividade Luiz'
__email__ = 'nativanando@gmail.com'

import matplotlib.pyplot as plt
import csv
import pandas as pd
import numpy as np

class BenchMarkMetrics:
	def __init__(self):
		self.df1 = pd.read_csv('results-512/log-out-1x1.txt')
		self.df2 = pd.read_csv('results-512/log-out-2x1.txt')
		self.df3 = pd.read_csv('results-512/log-out-2x2.txt')
		self.df4 = pd.read_csv('results-512/log-out-4x2.txt')
		self.df5 = pd.read_csv('results-512/log-out-6x2.txt')
		self.df6 = pd.read_csv('results-512/log-out-4x4.txt')

	def plot_graph_execution_time(self):
		# plt.plot(self.df1['time'])
		plt.plot(self.df1['time'], label='1 processor')
		plt.plot(self.df2['time'], label='2 processors')
		plt.plot(self.df3['time'], label='4 processors')
		plt.plot(self.df4['time'], label='8 processors')
		plt.plot(self.df5['time'], label='12 processors')
		plt.plot(self.df6['time'], label='16 processors')
		plt.title('CELTAB Cluster Metrics')
		plt.legend(loc='upper left')
		plt.xlabel('epochs')
		plt.ylabel('execution time (sec)')
   		plt.grid(True)
        	plt.savefig('assets/benchmark-512.png')

	def print_execution_time(self):
		with open('ExecutionTime-512.csv', 'w') as csvfile:
    			writer = csv.DictWriter(csvfile, fieldnames= ['amount_processor', 'time_max', 'speedup', 'efficiency'])
    			writer.writeheader()
    			writer.writerow({'amount_processor': 1, 'time_max': self.df1['time'].max()})
    			writer.writerow({'amount_processor': 2, 'time_max': self.df2['time'].max()})
    			writer.writerow({'amount_processor': 4, 'time_max': self.df3['time'].max()})
    			writer.writerow({'amount_processor': 8, 'time_max': self.df4['time'].max()})
    			writer.writerow({'amount_processor': 12, 'time_max': self.df5['time'].max()})
    			writer.writerow({'amount_processor': 16, 'time_max': self.df6['time'].max()})
			self.clear_buffer_plt()
			print(self.df1.describe())

	def speedup_calculation(self):
		# s(p) = t(1) / t(p)
		data = pd.read_csv('ExecutionTime-512.csv')
		for i in range(1, data['amount_processor'].count()):
			data['speedup'][i] = (data['time_max'][0] / data['time_max'][i])
			data['efficiency'][i] = (data['speedup'][i] / data['amount_processor'][i])
		data = self.clean_nan_values(data)
		data.to_csv('ExecutionTime-512.csv')

	def plot_graph_speedup(self):
		data = pd.read_csv('ExecutionTime-512.csv')
		plt.plot(data['amount_processor'], data['speedup'], label="IcoFoam Cavity Simulation", marker='o', linestyle='--', color='g')
		plt.title('CELTAB Cluster Metrics')
		plt.legend(loc='upper left')
		plt.xlabel('cores')
		plt.ylabel('speedup')
		plt.grid(True)
		plt.savefig('assets/speedup-512.png')
		self.clear_buffer_plt()

	def plot_graph_efficiency(self):
		data = pd.read_csv('ExecutionTime-512.csv')
		plt.plot(data['amount_processor'], data['efficiency'], label="IcoFoam Cavity Simulation", marker='o', linestyle='--', color='r')
		plt.title('CELTAB Cluster Metrics')
		plt.legend(loc='upper right')
		plt.xlabel('cores')
		plt.ylabel('efficiency')
		plt.grid(True)
		plt.savefig('assets/efficiency-512.png')
		self.clear_buffer_plt()

	def clean_nan_values(self, dataset):
		dataset = dataset.fillna(0)
		return dataset

	def clear_buffer_plt(self):
		plt.cla()
		plt.clf()


if __name__ == '__main__':
	plot = BenchMarkMetrics()
	plot.plot_graph_execution_time()
	plot.print_execution_time()
	plot.speedup_calculation()
	plot.plot_graph_speedup()
	plot.plot_graph_efficiency()
