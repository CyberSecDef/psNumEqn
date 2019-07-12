[CmdletBinding()] 
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)][int64]$number,
		[Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)][int64]$digit,
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)][int64]$limit
    )
	
Begin{
	
	class psNumEqn{
		$seen = @{}
		$operators = (new-object system.collections.stack)
		[int64]$minimum = 10
		[int64]$INT_MAX = 2147483647
		[int64]$number = 0
		[int64]$digit = 0
		
		psNumEqn($limit){
			$this.minimum = $limit
		}
		
		
		# function to find minimum levels in the recursive tree 
		minLevel([int64] $total, [int64] $N, [int64] $D, [int64] $level) { 
			# if total is equal to given N 
			if ($total -eq $N) { 
				# store if level is minimum 
				$this.minimum = [math]::min($this.minimum, $level); 
				return; 
			} 

			# if the last level is reached 
			if ($level -eq $this.minimum){
				return; 
			}
			
			# if total can be divided by D. 
			# recurse by dividing the total by D 
			if ($total % $D -eq 0){ 
				$this.minLevel($total / $D, $N, $D, $level + 1); 
			}
			
			# recurse for total + D 
			$this.minLevel($total + $D, $N, $D, $level + 1); 

			# if total - D is greater than 0 
			if ($total - $D > 0){ 
				# recurse for total - D 
				$this.minLevel($total - $D, $N, $D, $level + 1); 
			}
			# recurse for total multiply D 
			$this.minLevel($total * $D, $N, $D, $level + 1); 
		}

		[bool]generate([int64] $total, [int64] $N, [int64] $D, [int64] $level){
			# if total is equal to N 
			if ($total -eq $N){ 
				return $true;
			}

			# if the last level is reached 
			if ($level -eq $this.minimum){ 
				return $false; 
			}

			# if total is seen at level greater than current level 
			# or if we haven't seen total before. Mark the total 
			# as seen at current level 
			if ($this.seen[$total] -eq $null -or  $this.seen[$total] -ge $level) {
	
				$this.seen[$total] = $level; 

				[int64] $divide = $this.INT_MAX; 

				# if total is divisible by D 
				if ($total % $D -eq 0) { 
					$divide = $total / $D; 

					# if divide isn't seen before 
					# mark it as seen 
					if ($this.seen[$divide] -eq $null){
						$this.seen[$divide] = $level + 1; 
					}
				} 

				[int64] $addition = $total + $D; 

				# if addition isn't seen before 
				# mark it as seen 
				if ($this.seen[$addition] -eq $null){ 
					$this.seen[$addition] = $level + 1; 
				}

				[int64] $subtraction = $this.INT_MAX; 
				# if D can be subtracted from total 
				if ($total - $D -gt 0) { 
					$subtraction = $total - $D; 

					# if subtraction isn't seen before 
					# mark it as seen 
					if ($this.seen[$subtraction] -eq $null){
						$this.seen[$subtraction] = $level + 1; 
					}
				}

				[int64] $multiply = $total * $D; 

				# if multiply isn't seen before 
				# mark it as seen 
				if ($this.seen[$multiply] -eq $null){ 
					$this.seen[$multiply] = $level + 1; 
				}

				# recurse by dividing the total if possible 
				if ($divide -ne $this.INT_MAX){ 
					if ($this.generate($divide, $N, $D, $level + 1)) { 

						# store the operator. 
						$this.operators.push('/'); 
						return $true; 
					} 
				}

				# recurse by adding D to total 
				if ($this.generate($addition, $N, $D, $level + 1)) { 

					# store the operator. 
					$this.operators.push('+'); 
					return $true; 
				} 

				# recurse by subtracting D from total 
				if ($subtraction -ne $this.INT_MAX){ 
					if ($this.generate($subtraction, $N, $D, $level + 1)) { 

						# store the operator. 
						$this.operators.push('-'); 
						return $true; 
					} 
				}

				# recurse by multiplying D by total 
				if ($this.generate($multiply, $N, $D, $level + 1)) { 

					# store the operator. 
					$this.operators.push('*'); 
					return $true; 
				} 
			} 

			# expression is not found yet 
			return $false
		}
		
		#function to print the expression 
		printExpression([int64] $N, [int64] $D) {
			
			# find minimum level 
			$this.minLevel($D, $N, $D, 1); 

			# generate expression if possible 
			if ($this.generate($D, $N, $D, 1)) { 
				# stringstream for converting to D to string 
				[string] $num = ""; 
				$num = $num + $D; 

				[string] $expression = ""; 

				# if stack is not empty 
				if (!$this.operators.count -gt 0) { 

					# concatenate D and operator at top of stack 
					$expression = $num + $this.operators.peek(); 
					$this.operators.pop(); 
				} 

				# until stack is empty 
				# concatenate the operator with parenthesis for precedence 
				while ($this.operators.count -gt 0 ) { 
					if ($this.operators.peek() -eq '/' -or $this.operators.peek() -eq '*'){ 
						$expression = "(" + $expression + $num + ")" + $this.operators.peek(); 
					}else{
						$expression = $expression + $num + $this.operators.peek(); 
					}
					$this.operators.pop(); 
				} 

				$expression = $expression + $num; 

				write-host "Expression: $($expression)" 
			}else{
				write-host "Expression not found!"
			}
		} 
	}
}
Process{
	$numEqn = [psNumEqn]::new($limit)
	$numEqn.printExpression($number, $digit); 

}
End{

}
